build:
	docker build -t floodio/loadtest .

push:
	docker push floodio/loadtest

plan:
	terraform plan config

apply:
	terraform apply config

destroy:
	terraform destroy config

show:
	terraform show

loadtest:
	DOMAIN=$$(terraform output dns_name) ruby tests/load.rb
