# outputs.tf
# File này định nghĩa outputs để xem thông tin sau khi apply

# Output: Instance ID
output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.web.id
}

# Output: Public IP
output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.web.public_ip
}

# Output: Public DNS
output "instance_public_dns" {
  description = "Public DNS name of the EC2 instance"
  value       = aws_instance.web.public_dns
}

# Output: AMI ID used
output "ami_id" {
  description = "AMI ID used for the instance"
  value       = data.aws_ami.amazon_linux.id
}

# Output: Security Group ID
output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.web_sg.id
}


# Output: Website URL
output "website_url" {
  description = "URL to access the web server"
  value       = "http://${aws_instance.web.public_ip}"
}

# Output: All instance details (sensitive)
output "instance_details" {
  description = "All details of the EC2 instance"
  value = {
    id         = aws_instance.web.id
    type       = aws_instance.web.instance_type
    ami        = aws_instance.web.ami
    public_ip  = aws_instance.web.public_ip
    private_ip = aws_instance.web.private_ip
    monitoring = aws_instance.web.monitoring
    az         = aws_instance.web.availability_zone
  }
  sensitive = false
}