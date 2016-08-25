ROOT_DIR:=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

build:
	@docker build -t floodio/loadtest .

push:
	@docker push floodio/loadtest

elb:
	@cd terraform/elb && terraform apply -var-file=$(ROOT_DIR)/terraform.tfvars

elb-destroy:
	@cd terraform/elb && terraform destroy -var-file=$(ROOT_DIR)/terraform.tfvars

asg:
	@cd terraform/asg && TF_VAR_dd_api_key=$(DD_API_KEY) terraform apply -var-file=$(ROOT_DIR)/terraform.tfvars

asg-destroy:
	@cd terraform/asg && TF_VAR_dd_api_key=$(DD_API_KEY) terraform destroy -var-file=$(ROOT_DIR)/terraform.tfvars

api: elb_dns_name
	@cd terraform/api && TF_VAR_elb_dns_name=$(ELB_DNS_NAME) terraform apply -var-file=$(ROOT_DIR)/terraform.tfvars

api-destroy: elb_dns_name
	@cd terraform/api && TF_VAR_elb_dns_name=$(ELB_DNS_NAME) terraform destroy -var-file=$(ROOT_DIR)/terraform.tfvars

elb_dns_name:
	$(eval ELB_DNS_NAME := $(shell terraform output -state=terraform/elb/terraform.tfstate dns_name))

api_dns_name:
	$(eval API_DNS_NAME := $(shell terraform output -state=terraform/api/terraform.tfstate dns_name))

ping-elb: elb_dns_name
	@curl --silent --connect-timeout 3 http://$(ELB_DNS_NAME)/api | jq -r .

ping-api: api_dns_name
	@curl --silent --connect-timeout 3 https://$(API_DNS_NAME)/api/ | jq -r .

ping-elb-health:
	@aws --profile=flooded --region us-east-1 elb describe-instance-health --load-balancer-name flooded-elb | jq -r .

health-checks:
	@echo ELB instance health
	@make ping-elb-health
	@echo ELB nginx
	@make ping-elb
	@echo API
	@make ping-api

asg_first_ip:
	$(eval ASG_FIRST_IP := $(shell aws --profile=flooded --region us-east-1 ec2 describe-instances --filters "Name=tag-key,Values=aws:autoscaling:groupName" "Name=instance-state-name,Values=running" --query 'Reservations[].Instances[*].[Tags[?Key==`aws:autoscaling:groupName`] | [0].Value, PublicIpAddress]' --output text | sed 's/[[:space:]]/,/g' | sort -r| cut -d, -f2 | head -n1))

ssh-first: asg_first_ip
	ssh core@$(ASG_FIRST_IP)

loadtest: api_dns_name
	DOMAIN=$(API_DNS_NAME) ruby tests/load.rb
