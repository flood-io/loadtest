ROOT_DIR:=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

build:
	docker build -t floodio/loadtest .

push:
	docker push floodio/loadtest

elb:
	cd terraform/elb && terraform apply -var-file=$(ROOT_DIR)/terraform.tfvars

asg:
	cd terraform/asg && terraform apply -var-file=$(ROOT_DIR)/terraform.tfvars

api:
	cd terraform/api && terraform apply -var-file=$(ROOT_DIR)/terraform.tfvars

destroy:
	cd terraform/asg && terraform destroy -var-file=$(ROOT_DIR)/terraform.tfvars

ping:
	curl -I $$(cd terraform/elb && terraform output dns_name)

loadtest:
	DOMAIN=$$(cd terraform/asg && terraform output dns_name) ruby tests/load.rb
