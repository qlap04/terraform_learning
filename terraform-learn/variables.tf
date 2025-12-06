#Variable for AWS REGION
variable "aws_region" {
  description = "aws_region"
  type        = string
  default     = "us-east-1"
}

#Variable for Environment
variable "environment" {
  description = "env (prod, dev, staging)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}
# Variable cho SSH port
variable "ssh_port" {
  description = "SSH port number"
  type        = number
  default     = 22
}

#
variable "project_name" {
  description = "project_name"
  type        = string
  default     = "kai-project"
}

#Instance-type
variable "instance_type" {
  type    = string
  default = "t3.micro"
}
# Variable cho allowed SSH IPs
variable "allowed_ssh_ips" {
  description = "List of IPs allowed to SSH"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

# Variable cho enable monitoring
variable "enable_monitoring" {
  description = "Enable detailed monitoring"
  type        = bool
  default     = false
}

variable "custom_tags" {
  description = "Custom tags to add to resources"
  type        = map(string)
  default     = {}
}
