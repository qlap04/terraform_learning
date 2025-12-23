#Provider
variable "aws_region" {
  description = "AWS regional"
  type        = string
  default     = "ap-southeast-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod"
  }
}

variable "vpcs" {
  description = "Map of VPC configurations"
  type = map(object({
    cidr               = string
    azs                = list(string)
    private_subnets    = list(string)
    public_subnets     = list(string)
    enable_nat_gateway = bool
    tags               = map(string)
  }))
}