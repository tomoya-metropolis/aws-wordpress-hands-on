terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.92"
    }
  }

  required_version = ">= 1.2"
}

provider "aws" {
  region = "ap-northeast-1"
}

data "aws_vpc" "wordpress-vpc" {
  filter {
    name   = "tag:Name"
    values = ["wordpress-vpc"]
  }
}

resource "aws_lb_target_group" "wordpress-elb-target-group" {
  name     = "wordpress-elb-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.wordpress-vpc.id

  health_check {
    enabled  = true
    interval = 30
    path     = "/wp-includes/images/blank.gif"
    port     = "traffic-port"
    protocol = "HTTP"
  }
}

data "aws_instance" "wordpress-1a" {
  filter {
    name   = "tag:Name"
    values = ["wordpress-1a"]
  }
}

data "aws_instance" "wordpress-1c" {
  filter {
    name   = "tag:Name"
    values = ["wordpress-1c"]
  }
}

resource "aws_lb_target_group_attachment" "wordpress-1a-attachment" {
  target_group_arn = aws_lb_target_group.wordpress-elb-target-group.arn
  target_id        = data.aws_instance.wordpress-1a.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "wordpress-1c-attachment" {
  target_group_arn = aws_lb_target_group.wordpress-elb-target-group.arn
  target_id        = data.aws_instance.wordpress-1c.id
  port             = 80
}

data "aws_subnet" "public-1a" {
  filter {
    name   = "tag:Name"
    values = ["public-1a"]
  }
}

data "aws_subnet" "public-1c" {
  filter {
    name   = "tag:Name"
    values = ["public-1c"]
  }
}

data "aws_security_group" "wordpress-security-group" {
  filter {
    name   = "tag:Name"
    values = ["wordpress-security-group"]
  }
}

resource "aws_lb" "wordpress-lb" {
  name               = "wordpress-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [data.aws_security_group.wordpress-security-group.id]
  subnets            = [data.aws_subnet.public-1a.id, data.aws_subnet.public-1c.id]
}

resource "aws_lb_listener" "wordpress-lb-listener" {
  load_balancer_arn = aws_lb.wordpress-lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.wordpress-elb-target-group.arn
  }
}