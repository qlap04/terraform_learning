variable "os" {
  description = "OS name: amazon-linux-2, amazon-linux-2023, ubuntu-jammy"
  type        = string

  validation {
    condition = contains(["amazon-linux-2", "amazon-linux-2023", "ubuntu-jammy"], var.os)
    error_message = "Invalid OS name!"
  }
}
