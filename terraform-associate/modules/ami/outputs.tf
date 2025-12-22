output "id" {
  description = "AMI ID"
  value       = data.aws_ami.selected.id
}

output "name" {
  description = "AMI Name"
  value       = data.aws_ami.selected.name
}

