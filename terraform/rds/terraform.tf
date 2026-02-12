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

data "aws_security_group" "wordpress-security-group" {
  filter {
    name   = "tag:Name"
    values = ["wordpress-security-group"]
  }
}

resource "aws_security_group" "wordpress-rds-security-group" {
  name   = "wordpress-rds-security-group"
  vpc_id = data.aws_vpc.wordpress-vpc.id

  tags = {
    Name = "wordpress-rds-security-group"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_mysql" {
  security_group_id            = aws_security_group.wordpress-rds-security-group.id
  from_port                    = 3306
  ip_protocol                  = "tcp"
  to_port                      = 3306
  referenced_security_group_id = data.aws_security_group.wordpress-security-group.id
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.wordpress-rds-security-group.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = -1
}

data "aws_subnet" "private-1a" {
  filter {
    name   = "tag:Name"
    values = ["private-1a"]
  }
}

data "aws_subnet" "private-1c" {
  filter {
    name   = "tag:Name"
    values = ["private-1c"]
  }
}

resource "aws_db_subnet_group" "wordpress-db-subnet-group" {
  name       = "wordpress-db-subnet-group"
  subnet_ids = [data.aws_subnet.private-1a.id, data.aws_subnet.private-1c.id]

  tags = {
    Name = "wordpress-db-subnet-group"
  }
}

resource "aws_db_instance" "wordpress-rds" {
  allocated_storage    = 10
  db_name              = "wordpressdb"
  identifier           = "wordpressdb"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  username             = "admin"
  password             = "z3kLStLg"
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true
  multi_az             = true
  db_subnet_group_name = "wordpress-db-subnet-group"
  vpc_security_group_ids  = [aws_security_group.wordpress-rds-security-group.id]
}