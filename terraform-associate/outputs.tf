#App
output "app_details" {
  description = "All details of the App server"
  value = {
    id         = aws_instance.web-server.id
    type       = aws_instance.web-server.instance_type
    ami        = aws_instance.web-server.ami
    public_ip  = aws_instance.web-server.public_ip
    private_ip = aws_instance.web-server.private_ip
    az         = aws_instance.web-server.availability_zone
  }
  sensitive = false
}

output "db-server_details" {
  description = "All details of the DB server"
  value = {
    id         = aws_instance.db-server.id
    type       = aws_instance.db-server.instance_type
    ami        = aws_instance.db-server.ami
    public_ip  = aws_instance.db-server.public_ip
    private_ip = aws_instance.db-server.private_ip
    az         = aws_instance.db-server.availability_zone
  }
  sensitive = false
}

#Key Name
output "key_name" {
  description = "SSH Key pair name used for instances"
  value       = aws_instance.web-server.key_name
}

#SSH Commands
output "ssh_app_server" {
  description = "SSH command to connect to App Server"
  value       = "ssh -i ~/.ssh/EC2_fundamentals.pem ubuntu@${aws_instance.web-server.public_ip}"
}

output "ssh_db_server" {
  description = "SSH command to connect to DB Server"
  value       = "ssh -i ~/.ssh/EC2_fundamentals.pem ec2-user@${aws_instance.web-server.public_ip}"
}

#Database Info
output "db_connection_info" {
  description = "MariaDB connection details"
  value = {
    host     = aws_instance.db-server.private_ip
    port     = 3306
    database = "soccershop"
    username = "appuser"
    password = "AppPass123!"
  }
  sensitive = true
}

#Test Commands
output "test_db_from_app" {
  description = "Command to test DB connection from App Server"
  value       = "mysql -h ${aws_instance.db-server.private_ip} -u appuser -pAppPass123! -e 'SHOW DATABASES;'"
}

output "test_db_local" {
  description = "Command to test MariaDB locally on DB Server"
  value       = "mysql -u root -pRootPass123! -e 'SHOW DATABASES;'"
}

