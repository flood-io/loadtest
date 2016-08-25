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

api: domain
	cd terraform/api && TF_VAR_uri=$(DOMAIN) terraform apply -var-file=$(ROOT_DIR)/terraform.tfvars

api-destroy: domain
	cd terraform/api && TF_VAR_uri=$(DOMAIN) terraform destroy -var-file=$(ROOT_DIR)/terraform.tfvars

domain:
	$(eval DOMAIN := $(shell terraform output -state=terraform/elb/terraform.tfstate dns_name))

ping: domain
	curl -I $(DOMAIN)

loadtest: domain
	ruby tests/load.rb
