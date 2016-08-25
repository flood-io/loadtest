variable "profile" {}
variable "region" {}
variable "shared_credentials_file" {}

variable "uri" {}

provider "aws" {
  shared_credentials_file = "${var.shared_credentials_file}"
  profile = "${var.profile}"
  region = "${var.region}"
}

resource "aws_api_gateway_rest_api" "FloodedAPI" {
  name = "FloodedAPI"
  description = "Flooded API demo"
}

resource "aws_api_gateway_resource" "api_resource" {
  rest_api_id = "${aws_api_gateway_rest_api.FloodedAPI.id}"
  parent_id = "${aws_api_gateway_rest_api.FloodedAPI.root_resource_id}"
  path_part = "api"
}

resource "aws_api_gateway_method" "api_get" {
  rest_api_id = "${aws_api_gateway_rest_api.FloodedAPI.id}"
  resource_id = "${aws_api_gateway_resource.api_resource.id}"
  http_method = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "MyDemoIntegration" {
  rest_api_id = "${aws_api_gateway_rest_api.FloodedAPI.id}"
  resource_id = "${aws_api_gateway_resource.api_resource.id}"
  http_method = "${aws_api_gateway_method.api_get.http_method}"
  type = "HTTP"
  uri = "${var.uri}/api"
}