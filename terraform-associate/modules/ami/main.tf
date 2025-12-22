locals {
  ami_filters = {
    amazon-linux-2 = {
      owners = ["amazon"]
      name   = "amzn2-ami-hvm-*-x86_64-gp2"
    }

    amazon-linux-2023 = {
      owners = ["amazon"]
      name   = "al2023-ami-*-x86_64"
    }

    ubuntu-jammy = {
      owners = ["099720109477"] # Canonical
      name   = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
    }
  }
}

data "aws_ami" "selected" {
  owners      = local.ami_filters[var.os].owners
  most_recent = true

  filter {
    name   = "name"
    values = [local.ami_filters[var.os].name]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
