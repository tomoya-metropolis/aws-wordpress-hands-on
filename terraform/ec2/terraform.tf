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

data "aws_ami" "wordpress-ami" {
  most_recent = true
  name_regex  = "wordpress-*"
  owners      = ["self"]
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

resource "aws_instance" "wordpress-1a" {
  ami                         = data.aws_ami.wordpress-ami.id
  instance_type               = "t3.micro"
  subnet_id                   = data.aws_subnet.public-1a.id
  associate_public_ip_address = "true"
  key_name                    = "ec2"
  vpc_security_group_ids      = [aws_security_group.worpress-security-groups.id]

  tags = {
    Name = "wordpress-1a"
  }
}

resource "aws_instance" "wordpress-1c" {
  ami                         = data.aws_ami.wordpress-ami.id
  instance_type               = "t3.micro"
  subnet_id                   = data.aws_subnet.public-1c.id
  associate_public_ip_address = "true"
  key_name                    = "ec2"
  vpc_security_group_ids      = [aws_security_group.worpress-security-groups.id]

  tags = {
    Name = "wordpress-1c"
  }
}