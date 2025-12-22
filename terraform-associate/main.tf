#Module
module "ubuntu-jammy" {
  source = "./modules/ami"
  os     = "ubuntu-jammy"
}

module "amz-linux-2023" {
  source = "./modules/ami"
  os     = "amazon-linux-2023"
}

#SG
resource "aws_security_group" "app-sg" {
  name        = "${var.project}-${var.environment}-app-sg"
  description = "Security group for ${var.project} App Server in ${var.environment}"

  # Ingress rule
  ingress {
    description = "SSH from allowed IPs"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
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
    Name = "${var.project}-${var.environment}-app-sg"
  }
}

resource "aws_security_group" "db-sg" {
  name        = "${var.project}-${var.environment}-db-sg"
  description = "Security group for ${var.project} DB Server in ${var.environment}"

  # Ingress rule - SSH
  ingress {
    description = "SSH from allowed IPs"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Ingress rule - MariaDB from App Server
  ingress {
    description     = "MariaDB from App Server"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app-sg.id]
  }

  # Egress rule
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project}-${var.environment}-db-sg"
  }
}
#Resource
#App
resource "aws_instance" "web-server" {

  ami           = module.ubuntu-jammy.id
  instance_type = "t3.micro"
  key_name      = "EC2 fundamentals"

  vpc_security_group_ids = [aws_security_group.app-sg.id]

  user_data = <<-EOF
              #!/bin/bash
              # Update system
              apt-get update -y

              # Install MariaDB client for testing connectivity
              apt-get install mariadb-client -y
              EOF

  tags = {
    Name = "App Server"
    Type = "Micro"
  }
}

#DB
resource "aws_instance" "db-server" {

  ami           = module.amz-linux-2023.id
  instance_type = "t3.micro"
  key_name      = "EC2 fundamentals"

  vpc_security_group_ids = [aws_security_group.db-sg.id]

  user_data = <<-EOF
              #!/bin/bash
              # Update system
              yum update -y

              # Install MariaDB server
              yum install mariadb105-server -y

              # Start and enable MariaDB
              systemctl start mariadb
              systemctl enable mariadb

              # Secure MariaDB installation (set root password and basic security)
              mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY 'RootPass123!';"
              mysql -e "DELETE FROM mysql.user WHERE User='';"
              mysql -e "DROP DATABASE IF EXISTS test;"
              mysql -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';"

              # Create database and user for remote access
              mysql -u root -pRootPass123! -e "CREATE DATABASE soccershop;"
              mysql -u root -pRootPass123! -e "CREATE USER 'appuser'@'%' IDENTIFIED BY 'AppPass123!';"
              mysql -u root -pRootPass123! -e "GRANT ALL PRIVILEGES ON soccershop.* TO 'appuser'@'%';"
              mysql -u root -pRootPass123! -e "FLUSH PRIVILEGES;"

              # Configure MariaDB to listen on all interfaces
              sed -i 's/^bind-address.*/bind-address = 0.0.0.0/' /etc/my.cnf.d/mariadb-server.cnf

              # Restart MariaDB to apply changes
              systemctl restart mariadb
              EOF

  tags = {
    Name = "DB Server"
    Type = "Micro"
  }
}




