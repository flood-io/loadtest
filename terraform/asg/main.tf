variable "profile" {}
variable "region" {}
variable "shared_credentials_file" {}

variable "dd_api_key" {}

provider "aws" {
  shared_credentials_file = "${var.shared_credentials_file}"
  profile = "${var.profile}"
  region = "${var.region}"
}

resource "aws_launch_configuration" "flooded-launch-config" {
  name = "flooded-launch-config"
  image_id =  "ami-6d138f7a"
  # instance_type = "m3.medium"
  instance_type = "t2.micro"
  user_data = "${replace(file("cloudconfig.yml"), "DD_API_KEY", "${var.dd_api_key}")}"
  security_groups = ["allow_all"]
}

resource "aws_autoscaling_group" "flooded-asg" {
  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1d", "us-east-1e"]
  name = "flooded-asg"
  max_size = "3"
  min_size = "3"
  health_check_grace_period = 300
  health_check_type = "ELB"
  desired_capacity = "3"
  force_delete = true
  launch_configuration = "${aws_launch_configuration.flooded-launch-config.name}"
  load_balancers = ["flooded-elb"]
  tag {
    key = "Name"
    value = "flooded-asg"
    propagate_at_launch = true
  }
}
