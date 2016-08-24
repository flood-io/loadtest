variable "profile" {}
variable "region" {}
variable "shared_credentials_file" {}

provider "aws" {
  shared_credentials_file = "${var.shared_credentials_file}"
  profile = "${var.profile}"
  region = "${var.region}"
}

resource "aws_launch_configuration" "flooded-launch-config" {
  name = "flooded-launch-config"
  image_id =  "ami-6d138f7a"
  instance_type = "m3.medium"
  user_data = "${file("config/cloudconfig.yml")}"
  security_groups = ["${aws_security_group.flooded-sg.id}"]
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
  load_balancers = ["${aws_elb.flooded-elb.id}"]
}

resource "aws_security_group" "flooded-sg" {
  name = "allow_all"
  description = "Allow all web traffic"

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    self = true
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    self = true
  }

  ingress {
    from_port = 8008
    to_port = 8008
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    self = true
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    self = true
  }
}

resource "aws_elb" "flooded-elb" {
  name = "flooded-elb"
  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1d", "us-east-1e"]
  security_groups = ["${aws_security_group.flooded-sg.id}"]

  listener {
    instance_port = 8008
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    target = "HTTP:8008/"
    interval = 30
  }

  cross_zone_load_balancing = true
  idle_timeout = 400
  connection_draining = true
  connection_draining_timeout = 400
}

output "dns_name" {
  value = "${aws_elb.flooded-elb.dns_name}"
}
