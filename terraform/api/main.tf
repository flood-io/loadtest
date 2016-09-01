variable "profile" {}
variable "region" {}
variable "shared_credentials_file" {}

variable "elb_dns_name" {}

provider "aws" {
  shared_credentials_file = "${var.shared_credentials_file}"
  profile = "${var.profile}"
  region = "${var.region}"
}

##
# /api

resource "aws_api_gateway_rest_api" "api_flooded" {
  name = "api_flooded"
  description = "Flooded API demo"
}

resource "aws_api_gateway_method" "root_get" {
  rest_api_id = "${aws_api_gateway_rest_api.api_flooded.id}"
  resource_id = "${aws_api_gateway_rest_api.api_flooded.root_resource_id}"
  http_method = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "root_get_integration" {
  rest_api_id = "${aws_api_gateway_rest_api.api_flooded.id}"
  resource_id = "${aws_api_gateway_rest_api.api_flooded.root_resource_id}"
  http_method = "${aws_api_gateway_method.root_get.http_method}"
  integration_http_method = "${aws_api_gateway_method.root_get.http_method}"
  type = "HTTP"
  uri = "http://${var.elb_dns_name}/api"
}

resource "aws_api_gateway_method_response" "root_get_200" {
  rest_api_id = "${aws_api_gateway_rest_api.api_flooded.id}"
  resource_id = "${aws_api_gateway_rest_api.api_flooded.root_resource_id}"
  http_method = "${aws_api_gateway_method.root_get.http_method}"
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "root_get_integration_response" {
  rest_api_id = "${aws_api_gateway_rest_api.api_flooded.id}"
  resource_id = "${aws_api_gateway_rest_api.api_flooded.root_resource_id}"
  http_method = "${aws_api_gateway_method.root_get.http_method}"
  status_code = "${aws_api_gateway_method_response.root_get_200.status_code}"
}

##
# /api/oauth

resource "aws_api_gateway_resource" "oauth" {
  rest_api_id = "${aws_api_gateway_rest_api.api_flooded.id}"
  parent_id = "${aws_api_gateway_rest_api.api_flooded.root_resource_id}"
  path_part = "oauth"
}

resource "aws_api_gateway_method" "oauth_post" {
  rest_api_id = "${aws_api_gateway_rest_api.api_flooded.id}"
  resource_id = "${aws_api_gateway_resource.oauth.id}"
  http_method = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "oauth_post_integration" {
  rest_api_id = "${aws_api_gateway_rest_api.api_flooded.id}"
  resource_id = "${aws_api_gateway_resource.oauth.id}"
  http_method = "${aws_api_gateway_method.oauth_post.http_method}"
  integration_http_method = "${aws_api_gateway_method.oauth_post.http_method}"
  type = "HTTP"
  uri = "http://${var.elb_dns_name}/api/oauth"
}

resource "aws_api_gateway_method_response" "oauth_post_200" {
  rest_api_id = "${aws_api_gateway_rest_api.api_flooded.id}"
  resource_id = "${aws_api_gateway_resource.oauth.id}"
  http_method = "${aws_api_gateway_method.oauth_post.http_method}"
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "oauth_post_integration_response" {
  rest_api_id = "${aws_api_gateway_rest_api.api_flooded.id}"
  resource_id = "${aws_api_gateway_resource.oauth.id}"
  http_method = "${aws_api_gateway_method.oauth_post.http_method}"
  status_code = "${aws_api_gateway_method_response.oauth_post_200.status_code}"
}

resource "aws_api_gateway_method" "oauth_delete" {
  rest_api_id = "${aws_api_gateway_rest_api.api_flooded.id}"
  resource_id = "${aws_api_gateway_resource.oauth.id}"
  http_method = "DELETE"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "oauth_delete_integration" {
  rest_api_id = "${aws_api_gateway_rest_api.api_flooded.id}"
  resource_id = "${aws_api_gateway_resource.oauth.id}"
  http_method = "${aws_api_gateway_method.oauth_delete.http_method}"
  integration_http_method = "${aws_api_gateway_method.oauth_delete.http_method}"
  type = "HTTP"
  uri = "http://${var.elb_dns_name}/api/oauth"
}

resource "aws_api_gateway_method_response" "oauth_delete_200" {
  rest_api_id = "${aws_api_gateway_rest_api.api_flooded.id}"
  resource_id = "${aws_api_gateway_resource.oauth.id}"
  http_method = "${aws_api_gateway_method.oauth_delete.http_method}"
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "oauth_delete_integration_response" {
  rest_api_id = "${aws_api_gateway_rest_api.api_flooded.id}"
  resource_id = "${aws_api_gateway_resource.oauth.id}"
  http_method = "${aws_api_gateway_method.oauth_delete.http_method}"
  status_code = "${aws_api_gateway_method_response.oauth_delete_200.status_code}"
}

##
# /api/search

resource "aws_api_gateway_resource" "search" {
  rest_api_id = "${aws_api_gateway_rest_api.api_flooded.id}"
  parent_id = "${aws_api_gateway_rest_api.api_flooded.root_resource_id}"
  path_part = "search"
}

resource "aws_api_gateway_method" "search_get" {
  rest_api_id = "${aws_api_gateway_rest_api.api_flooded.id}"
  resource_id = "${aws_api_gateway_resource.search.id}"
  http_method = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "search_get_integration" {
  rest_api_id = "${aws_api_gateway_rest_api.api_flooded.id}"
  resource_id = "${aws_api_gateway_resource.search.id}"
  http_method = "${aws_api_gateway_method.search_get.http_method}"
  integration_http_method = "${aws_api_gateway_method.search_get.http_method}"
  type = "HTTP"
  uri = "http://${var.elb_dns_name}/api/path"
}

resource "aws_api_gateway_method_response" "search_get_200" {
  rest_api_id = "${aws_api_gateway_rest_api.api_flooded.id}"
  resource_id = "${aws_api_gateway_resource.search.id}"
  http_method = "${aws_api_gateway_method.search_get.http_method}"
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "search_get_integration_response" {
  rest_api_id = "${aws_api_gateway_rest_api.api_flooded.id}"
  resource_id = "${aws_api_gateway_resource.search.id}"
  http_method = "${aws_api_gateway_method.search_get.http_method}"
  status_code = "${aws_api_gateway_method_response.search_get_200.status_code}"
}

##
# /api/shipping

resource "aws_api_gateway_resource" "shipping" {
  rest_api_id = "${aws_api_gateway_rest_api.api_flooded.id}"
  parent_id = "${aws_api_gateway_rest_api.api_flooded.root_resource_id}"
  path_part = "shipping"
}

resource "aws_api_gateway_method" "shipping_get" {
  rest_api_id = "${aws_api_gateway_rest_api.api_flooded.id}"
  resource_id = "${aws_api_gateway_resource.shipping.id}"
  http_method = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "shipping_get_integration" {
  rest_api_id = "${aws_api_gateway_rest_api.api_flooded.id}"
  resource_id = "${aws_api_gateway_resource.shipping.id}"
  http_method = "${aws_api_gateway_method.shipping_get.http_method}"
  integration_http_method = "${aws_api_gateway_method.shipping_get.http_method}"
  type = "HTTP"
  uri = "http://${var.elb_dns_name}/api/path"
}

resource "aws_api_gateway_method_response" "shipping_get_200" {
  rest_api_id = "${aws_api_gateway_rest_api.api_flooded.id}"
  resource_id = "${aws_api_gateway_resource.shipping.id}"
  http_method = "${aws_api_gateway_method.shipping_get.http_method}"
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "shipping_get_integration_response" {
  rest_api_id = "${aws_api_gateway_rest_api.api_flooded.id}"
  resource_id = "${aws_api_gateway_resource.shipping.id}"
  http_method = "${aws_api_gateway_method.shipping_get.http_method}"
  status_code = "${aws_api_gateway_method_response.shipping_get_200.status_code}"
}

##
# /api/cart

resource "aws_api_gateway_resource" "cart" {
  rest_api_id = "${aws_api_gateway_rest_api.api_flooded.id}"
  parent_id = "${aws_api_gateway_rest_api.api_flooded.root_resource_id}"
  path_part = "cart"
}

resource "aws_api_gateway_method" "cart_get" {
  rest_api_id = "${aws_api_gateway_rest_api.api_flooded.id}"
  resource_id = "${aws_api_gateway_resource.cart.id}"
  http_method = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "cart_get_integration" {
  rest_api_id = "${aws_api_gateway_rest_api.api_flooded.id}"
  resource_id = "${aws_api_gateway_resource.cart.id}"
  http_method = "${aws_api_gateway_method.cart_get.http_method}"
  integration_http_method = "${aws_api_gateway_method.cart_get.http_method}"
  type = "HTTP"
  uri = "http://${var.elb_dns_name}/api/path"
}

resource "aws_api_gateway_method_response" "cart_get_200" {
  rest_api_id = "${aws_api_gateway_rest_api.api_flooded.id}"
  resource_id = "${aws_api_gateway_resource.cart.id}"
  http_method = "${aws_api_gateway_method.cart_get.http_method}"
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "cart_get_integration_response" {
  rest_api_id = "${aws_api_gateway_rest_api.api_flooded.id}"
  resource_id = "${aws_api_gateway_resource.cart.id}"
  http_method = "${aws_api_gateway_method.cart_get.http_method}"
  status_code = "${aws_api_gateway_method_response.cart_get_200.status_code}"
}

resource "aws_api_gateway_method" "cart_post" {
  rest_api_id = "${aws_api_gateway_rest_api.api_flooded.id}"
  resource_id = "${aws_api_gateway_resource.cart.id}"
  http_method = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "cart_post_integration" {
  rest_api_id = "${aws_api_gateway_rest_api.api_flooded.id}"
  resource_id = "${aws_api_gateway_resource.cart.id}"
  http_method = "${aws_api_gateway_method.cart_post.http_method}"
  integration_http_method = "${aws_api_gateway_method.cart_post.http_method}"
  type = "HTTP"
  uri = "http://${var.elb_dns_name}/api/path"
}

resource "aws_api_gateway_method_response" "cart_post_200" {
  rest_api_id = "${aws_api_gateway_rest_api.api_flooded.id}"
  resource_id = "${aws_api_gateway_resource.cart.id}"
  http_method = "${aws_api_gateway_method.cart_post.http_method}"
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "cart_post_integration_response" {
  rest_api_id = "${aws_api_gateway_rest_api.api_flooded.id}"
  resource_id = "${aws_api_gateway_resource.cart.id}"
  http_method = "${aws_api_gateway_method.cart_post.http_method}"
  status_code = "${aws_api_gateway_method_response.cart_post_200.status_code}"
}

resource "aws_api_gateway_method" "cart_delete" {
  rest_api_id = "${aws_api_gateway_rest_api.api_flooded.id}"
  resource_id = "${aws_api_gateway_resource.cart.id}"
  http_method = "DELETE"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "cart_delete_integration" {
  rest_api_id = "${aws_api_gateway_rest_api.api_flooded.id}"
  resource_id = "${aws_api_gateway_resource.cart.id}"
  http_method = "${aws_api_gateway_method.cart_delete.http_method}"
  integration_http_method = "${aws_api_gateway_method.cart_delete.http_method}"
  type = "HTTP"
  uri = "http://${var.elb_dns_name}/api/path"
}

resource "aws_api_gateway_method_response" "cart_delete_200" {
  rest_api_id = "${aws_api_gateway_rest_api.api_flooded.id}"
  resource_id = "${aws_api_gateway_resource.cart.id}"
  http_method = "${aws_api_gateway_method.cart_delete.http_method}"
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "cart_delete_integration_response" {
  rest_api_id = "${aws_api_gateway_rest_api.api_flooded.id}"
  resource_id = "${aws_api_gateway_resource.cart.id}"
  http_method = "${aws_api_gateway_method.cart_delete.http_method}"
  status_code = "${aws_api_gateway_method_response.cart_delete_200.status_code}"
}

output "dns_name" {
  value = "${aws_api_gateway_rest_api.api_flooded.id}.execute-api.us-west-2.amazonaws.com"
}
