packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "wordpress" {
  ami_name      = "wordpress"
  instance_type = "t2.small"
  region        = "ap-northeast-1"
  source_ami    = "ami-00d73f83fa9a60285"
  ssh_username  = "ec2-user"
}

build {
  name = "wordpress"
  sources = [
    "source.amazon-ebs.wordpress"
  ]

  provisioner "ansible" {
    playbook_file   = "../ansible/site.yml"
    extra_arguments = ["--extra-vars", "ansible_python_interpreter=/usr/bin/python3"]
  }
}