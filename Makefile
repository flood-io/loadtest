.PHONY: list

list:
	@awk -F: '/^[A-z]/ {print $$1}' Makefile | sort

_ROOT_DIR:=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

build:
	@docker build -t floodio/loadtest .

push:
	@docker push floodio/loadtest

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
	  -F "grid[instance_quantity]=5" \
	  -F "grid[stop_after]=240" \
	  -F "grid[instance_type]=m4.xlarge" | jq -r .

create_grid_control:
	@curl --silent -u ${FLOOD_API_TOKEN}: -X POST https://api.flood.io/grids \
	  -F "grid[region]=us-west-1" \
	  -F "grid[infrastructure]=demand" \
	  -F "grid[instance_quantity]=1" \
	  -F "grid[stop_after]=240" \
	  -F "grid[instance_type]=m4.xlarge" | jq -r .

get_elb_dns_name:
	$(eval ELB_DNS_NAME := $(shell terraform output -state=terraform/elb/terraform.tfstate dns_name))

get_api_dns_name:
	$(eval API_DNS_NAME := $(shell terraform output -state=terraform/api/terraform.tfstate dns_name))

get_asg_first_ip:
	$(eval ASG_FIRST_IP := $(shell aws --profile=flooded --region us-west-2 ec2 describe-instances --filters "Name=tag-key,Values=aws:autoscaling:groupName" "Name=instance-state-name,Values=running" --query 'Reservations[].Instances[*].[Tags[?Key==`aws:autoscaling:groupName`] | [0].Value, PublicIpAddress]' --output text | sed 's/[[:space:]]/,/g' | sort -r| cut -d, -f2 | head -n1))

ssh_to_first_node: get_asg_first_ip
	ssh core@$(ASG_FIRST_IP)

check_elb: get_elb_dns_name
	@echo ELB: $(ELB_DNS_NAME)
	@curl --silent --connect-timeout 3 http://$(ELB_DNS_NAME)/api | jq -r .

check_api: get_api_dns_name
	@echo API: $(API_DNS_NAME)
	@curl --silent --connect-timeout 3 https://$(API_DNS_NAME)/api/ | jq -r .

check_health:
	@echo ELB instance health
	@aws --profile=flooded --region us-west-2 elb describe-instance-health --load-balancer-name flooded-elb | jq -r .
	@make check_elb
	@make check_api
	@echo Grids
	@make check_grids

check_grids:
	@curl --silent -u ${FLOOD_API_TOKEN}: -X GET https://api.flood.io/grids \
		| jq -r '._embedded.grids[] | select(.infrastructure == "demand") | [.name,.status,.region,.instance_quantity]'

loadtest: get_api_dns_name
	@DOMAIN=$(API_DNS_NAME) ruby tests/load.rb

loadtest_elb: get_elb_dns_name
	@DOMAIN=$(ELB_DNS_NAME) PORT=80 PROTOCOL=http REGION=us-west-2 THREADS=1000 ruby tests/load.rb

loadtest_elb_control: get_elb_dns_name
	@DOMAIN=$(ELB_DNS_NAME) PORT=80 PROTOCOL=http REGION=us-west-1 THREADS=10 ruby tests/load.rb
