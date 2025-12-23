terraform {
  cloud {

    organization = "Kai-SE"

    workspaces {
      name = "remote-dev-backend"
    }
  }
}

# Tạo VPC cho mỗi environment bằng for_each
# VPC Module với for_each
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.5.1"

  for_each = var.vpcs

  name = "${var.environment}-${each.key}-vpc"
  cidr = each.value.cidr

  azs             = each.value.azs
  private_subnets = each.value.private_subnets
  public_subnets  = each.value.public_subnets

  enable_nat_gateway   = each.value.enable_nat_gateway
  enable_dns_hostnames = true

  tags = merge(
    each.value.tags,
    {
      Name        = "${var.environment}-${each.key}-vpc"
      Environment = var.environment
    }
  )
}