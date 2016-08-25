ROOT_DIR:=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

build:
	docker build -t floodio/loadtest .

push:
	docker push floodio/loadtest

elb:
	cd terraform/elb && terraform apply -var-file=$(ROOT_DIR)/terraform.tfvars

elb-destroy:
	cd terraform/elb && terraform destroy -var-file=$(ROOT_DIR)/terraform.tfvars

asg:
	cd terraform/asg && terraform apply -var-file=$(ROOT_DIR)/terraform.tfvars

asg-destroy:
	cd terraform/asg && terraform destroy -var-file=$(ROOT_DIR)/terraform.tfvars

api: elb_dns_name
	cd terraform/api && TF_VAR_elb_dns_name=$(ELB_DNS_NAME) terraform apply -var-file=$(ROOT_DIR)/terraform.tfvars

api-destroy: elb_dns_name
	cd terraform/api && TF_VAR_elb_dns_name=$(ELB_DNS_NAME) terraform destroy -var-file=$(ROOT_DIR)/terraform.tfvars

elb_dns_name:
	$(eval ELB_DNS_NAME := $(shell terraform output -state=terraform/elb/terraform.tfstate dns_name))

api_dns_name:
	$(eval API_DNS_NAME := $(shell terraform output -state=terraform/api/terraform.tfstate dns_name))

ping-elb: elb_dns_name
	curl -I http://$(ELB_DNS_NAME)

ping-api: api_dns_name
	curl https://$(API_DNS_NAME)/api/

loadtest: api_dns_name
	DOMAIN=$(API_DNS_NAME) ruby tests/load.rb
