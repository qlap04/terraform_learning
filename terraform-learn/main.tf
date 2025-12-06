
#DATA SRC
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023*"]
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

#Create sg
resource "aws_security_group" "web_sg" {
  name        = "${var.project_name}-${var.environment}-sg"
  description = "Security group for ${var.project_name} in ${var.environment}"

  # Ingress rule
  ingress {
    description = "SSH from allowed IPs"
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = "tcp"
    cidr_blocks = var.allowed_ssh_ips
  }

  # Ingress rule
  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Egress rule
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # -1 = all protocols
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-sg"
  }
}


# RESOURCE 2: EC2 Instance
resource "aws_instance" "web" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type

  # Gắn security group
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  # Enable detailed monitoring (từ variable)
  monitoring = var.enable_monitoring

  # User data - Script chạy khi instance khởi động
  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Hello from Terraform - ${var.environment}</h1>" > /var/www/html/index.html
              EOF

  # Lifecycle: Tạo cái mới trước khi xóa cái cũ
  lifecycle {
    create_before_destroy = true
  }

  # Tags
  tags = merge(
    {
      Name = "${var.project_name}-${var.environment}-web"
    },
    var.custom_tags
  )
}