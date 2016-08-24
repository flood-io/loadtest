build:
	docker build -t floodio/loadtest .

push:
	docker push floodio/loadtest

plan:
	cd config && terraform plan

apply:
	cd config && terraform apply

destroy:
	cd config && terraform destroy

show:
	cd config && terraform show

load:
	ruby tests/load.rb
