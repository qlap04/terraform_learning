# VPC Outputs
output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "VPC CIDR block"
  value       = aws_vpc.main.cidr_block
}

# Subnet Outputs
output "public_subnet_id" {
  description = "Public subnet ID"
  value       = aws_subnet.public.id
}

output "private_subnet_id" {
  description = "Private subnet ID"
  value       = aws_subnet.private.id
}

# Web Server Outputs
output "web_server_id" {
  description = "Web server instance ID"
  value       = aws_instance.web.id
}

output "web_server_public_ip" {
  description = "Web server public IP"
  value       = aws_instance.web.public_ip
}

output "web_server_private_ip" {
  description = "Web server private IP"
  value       = aws_instance.web.private_ip
}

# Database Server Outputs
output "db_server_id" {
  description = "Database server instance ID"
  value       = aws_instance.db.id
}

output "db_server_private_ip" {
  description = "Database server private IP"
  value       = aws_instance.db.private_ip
}

# Key Pair Output
output "key_pair_used" {
  description = "Key pair name used"
  value       = var.key_pair_name
}

# Connection Info
output "web_url" {
  description = "URL to access web server"
  value       = "http://${aws_instance.web.public_ip}"
}

# ← SSH COMMANDS - QUAN TRỌNG!
output "ssh_web_command" {
  description = "SSH command for web server"
  value       = "ssh -i '~/.ssh/EC2_fundamentals.pem' ec2-user@${aws_instance.web.public_ip}"
}

output "ssh_db_via_web" {
  description = "How to SSH to DB server via Web server"
  value       = <<-EOT
  
  🔐 SSH TO DATABASE SERVER (via Bastion/Web):
  
  Step 1: Copy key to web server (one-time setup)
  -----------------------------------------------
  scp -i "~/.ssh/EC2_fundamentals.pem" "EC2_fundamentals.pem" ec2-user@${aws_instance.web.public_ip}:~/
  
  Step 2: SSH to web server
  -------------------------
  ssh -i "EC2_fundamentals.pem" ec2-user@${aws_instance.web.public_ip}
  
  Step 3: From web server, SSH to DB server
  ------------------------------------------
  chmod 400 ~/EC2_fundamentals.pem
  ssh -i "~/EC2_fundamentals.pem" ec2-user@${aws_instance.db.private_ip}
  
  OR use SSH Agent Forwarding (recommended):
  ------------------------------------------
  ssh -A -i "~/.ssh/EC2_fundamentals.pem" ec2-user@${aws_instance.web.public_ip}
  ssh ec2-user@${aws_instance.db.private_ip}
  
  EOT
}

output "architecture_summary" {
  description = "Architecture summary"
  value = {
    vpc_cidr            = aws_vpc.main.cidr_block
    public_subnet_cidr  = aws_subnet.public.cidr_block
    private_subnet_cidr = aws_subnet.private.cidr_block
    web_server_public   = aws_instance.web.public_ip
    web_server_private  = aws_instance.web.private_ip
    db_server_private   = aws_instance.db.private_ip
    key_pair            = var.key_pair_name
  }
}