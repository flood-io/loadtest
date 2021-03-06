.PHONY: list

list:
	@awk -F: '/^[A-z]/ {print $$1}' Makefile | sort

_ROOT_DIR:=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
API_VERSION:=v2

build:
	@docker build -t floodio/loadtest .

push:
	@docker push floodio/loadtest

run:
	@docker run -it -p 8008:8008 floodio/loadtest

create_elb:
	@cd terraform/elb && terraform apply -var-file=$(_ROOT_DIR)/terraform.tfvars

destroy_elb:
	@cd terraform/elb && terraform destroy -var-file=$(_ROOT_DIR)/terraform.tfvars

create_asg:
	@cd terraform/asg && TF_VAR_dd_api_key=$(DD_API_KEY) terraform apply -var-file=$(_ROOT_DIR)/terraform.tfvars

destroy_asg:
	@cd terraform/asg && TF_VAR_dd_api_key=$(DD_API_KEY) terraform destroy -var-file=$(_ROOT_DIR)/terraform.tfvars

create_api: get_elb_dns_name
	@cd terraform/api && TF_VAR_elb_dns_name=$(ELB_DNS_NAME) terraform apply -var-file=$(_ROOT_DIR)/terraform.tfvars

destroy_api: get_elb_dns_name
	@cd terraform/api && TF_VAR_elb_dns_name=$(ELB_DNS_NAME) terraform destroy -var-file=$(_ROOT_DIR)/terraform.tfvars

create_grid:
	@curl --silent -u ${FLOOD_API_TOKEN}: -X POST https://api.flood.io/grids \
	  -F "grid[region]=us-west-2" \
	  -F "grid[infrastructure]=demand" \
	  -F "grid[instance_quantity]=90" \
	  -F "grid[stop_after]=600" \
	  -F "grid[instance_type]=m4.xlarge" | jq -r .

create_grid_canary:
	@curl --silent -u ${FLOOD_API_TOKEN}: -X POST https://api.flood.io/grids \
	  -F "grid[region]=us-west-1" \
	  -F "grid[infrastructure]=demand" \
	  -F "grid[instance_quantity]=1" \
	  -F "grid[stop_after]=600" \
	  -F "grid[instance_type]=m4.xlarge" | jq -r .

create_grids:
	@make create_grid
	@make create_grid_canary

get_elb_dns_name:
	$(eval ELB_DNS_NAME := $(shell terraform output -state=terraform/elb/terraform.tfstate dns_name))

get_api_dns_name:
	$(eval API_DNS_NAME := $(shell terraform output -state=terraform/api/terraform.tfstate dns_name))

get_asg_first_ip:
	$(eval ASG_FIRST_IP := $(shell aws --profile=flooded --region us-west-2 ec2 describe-instances --filters "Name=tag-key,Values=aws:autoscaling:groupName" "Name=instance-state-name,Values=running" --query 'Reservations[].Instances[*].[Tags[?Key==`aws:autoscaling:groupName`] | [0].Value, PublicIpAddress]' --output text | sed 's/[[:space:]]/,/g' | sort -r| cut -d, -f2 | head -n1))

ssh_to_first_node: get_asg_first_ip
	ssh core@$(ASG_FIRST_IP)

check_asg:
	@aws --profile=flooded --region us-west-2 elb describe-instance-health --load-balancer-name flooded-elb | jq -r '.InstanceStates[] | .State' | sort | uniq -c | sort

check_elb: get_elb_dns_name
	@echo ELB: $(ELB_DNS_NAME)
	@curl --silent --connect-timeout 3 http://$(ELB_DNS_NAME)/api | jq -r .status | uniq -c | sort

check_api: get_api_dns_name
	@echo API: $(API_DNS_NAME)
	@curl --silent --connect-timeout 3 https://$(API_DNS_NAME)/$(API_VERSION) | jq -r .status | uniq -c | sort

check_grids:
	@curl --silent --user ${FLOOD_API_TOKEN}: https://api.flood.io/grids | jq -r -c '._embedded.grids[] | select(.infrastructure == "demand") | .region as $$region| ._embedded.nodes[] | [.health, $$region] | @tsv' | sort | uniq -c | sort

check_health:
	@echo ASG: flooded-asg
	@make check_asg
	@make check_elb
	@make check_api
	@echo GRIDS:
	@make check_grids

baseline: get_elb_dns_name
	@echo "Starting baseline test for ELB us-west-1"
	@DOMAIN=$(ELB_DNS_NAME) VERSION=api PORT=80 PROTOCOL=http REGION=us-west-1 THREADS=50 FLOOD_NAME="ELB baseline" ruby tests/load.rb

shakeout: get_api_dns_name
	@echo "Starting shakeout test for API us-west-1"
	@DOMAIN=$(API_DNS_NAME) VERSION=$(API_VERSION) PORT=443 PROTOCOL=https REGION=us-west-1 THREADS=500 FLOOD_NAME="API shakeout" ruby tests/load.rb

loadtest: get_api_dns_name
	@echo "Starting canary test for API us-west-1"
	@DOMAIN=$(API_DNS_NAME) VERSION=$(API_VERSION) PORT=443 PROTOCOL=https REGION=us-west-1 THREADS=50 FLOOD_NAME="API canary test" ruby tests/load.rb
	@echo "Starting main test for API us-west-2"
	@DOMAIN=$(API_DNS_NAME) VERSION=$(API_VERSION) PORT=443 PROTOCOL=https REGION=us-west-2 THREADS=500 FLOOD_NAME="API load test" ruby tests/load.rb

loadtest_elb: get_elb_dns_name
	@echo "Starting canary test for ELB us-west-1"
	@DOMAIN=$(ELB_DNS_NAME) VERSION=api PORT=80 PROTOCOL=http REGION=us-west-1 THREADS=50 FLOOD_NAME="ELB canary test" ruby tests/load.rb
	@echo "Starting main test for ELB us-west-2"
	@DOMAIN=$(ELB_DNS_NAME) VERSION=api PORT=80 PROTOCOL=http REGION=us-west-2 THREADS=500 FLOOD_NAME="ELB load test" ruby tests/load.rb

spike: get_api_dns_name
	@echo "Starting canary test for API us-west-1"
	@DOMAIN=$(API_DNS_NAME) VERSION=$(API_VERSION) PORT=443 PROTOCOL=https REGION=us-west-1 THREADS=50 FLOOD_NAME="API canary test" ruby tests/load.rb
	@echo "Starting main test for API us-west-2"
	@DOMAIN=$(API_DNS_NAME) VERSION=$(API_VERSION) PORT=443 PROTOCOL=https REGION=us-west-2 THREADS=500 FLOOD_NAME="API spike test" ruby tests/spike.rb

spike_elb: get_elb_dns_name
	@echo "Starting canary test for API us-west-1"
	@DOMAIN=$(ELB_DNS_NAME) VERSION=api PORT=80 PROTOCOL=http REGION=us-west-1 THREADS=50 FLOOD_NAME="API canary test" ruby tests/load.rb
	@echo "Starting main test for API us-west-2"
	@DOMAIN=$(ELB_DNS_NAME) VERSION=api PORT=80 PROTOCOL=http REGION=us-west-2 THREADS=500 FLOOD_NAME="API spike test" ruby tests/spike.rb

spike_demo:
	@echo "Starting main test for API us-west-2"
	@DOMAIN=flooded.io VERSION=api PORT=80 PROTOCOL=http REGION=us-west-2 THREADS=500 FLOOD_NAME="API spike test" bundle exec ruby tests/spike.rb
