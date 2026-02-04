terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.92"
    }
  }

  required_version = ">= 1.2"
}

data "aws_vpc" "wordpress-vpc" {
  filter {
    name   = "tag:Name"
    values = ["wordpress-vpc"]
  }
}

resource "aws_security_group" "worpress-security-groups" {
  name   = "worpress-security-groups"
  vpc_id = data.aws_vpc.wordpress-vpc.id

  tags = {
    Name = "worpress-security-groups"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.worpress-security-groups.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  security_group_id = aws_security_group.worpress-security-groups.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.worpress-security-groups.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}