variable "project" {
  type    = string
  default = "soccer shop"
}

variable "managedBy" {
  description = "Manager"
  type        = string
  default     = "Kai Devops"
}

variable "environment" {
  description = "Environment for product"
  type        = string

  validation {
    condition     = contains(["dev", "prod", "staging"], var.environment)
    error_message = "environment must be one of: dev, prod, staging."
  }

  default = "dev"
}
