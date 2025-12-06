# ============================================
# VPC
# ============================================
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.environment}-vpc"
  }
}

# ============================================
# INTERNET GATEWAY
# ============================================
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id # ← Implicit dependency!

  tags = {
    Name = "${var.environment}-igw"
  }
}

# ============================================
# PUBLIC SUBNET
# ============================================
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true # Auto-assign public IP

  tags = {
    Name = "${var.environment}-public-subnet"
    Type = "Public"
  }
}

# ============================================
# PRIVATE SUBNET
# ============================================
resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = var.availability_zone

  tags = {
    Name = "${var.environment}-private-subnet"
    Type = "Private"
  }
}

# ============================================
# ROUTE TABLE cho PUBLIC SUBNET
# ============================================
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  # Route to Internet Gateway
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id # ← Implicit dependency!
  }

  tags = {
    Name = "${var.environment}-public-rt"
  }
}

# Associate Route Table với Public Subnet
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# ============================================
# ROUTE TABLE cho PRIVATE SUBNET (default)
# ============================================
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  # Không có route to internet
  # Chỉ có local routes (tự động)

  tags = {
    Name = "${var.environment}-private-rt"
  }
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

# ============================================
# SECURITY GROUP cho Web Server (Public)
# ============================================
resource "aws_security_group" "web" {
  name        = "${var.environment}-web-sg"
  description = "Security group for web servers"
  vpc_id      = aws_vpc.main.id

  # HTTP
  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS
  ingress {
    description = "HTTPS from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SSH (chỉ từ IP của em)
  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # ⚠️ Production: Thay bằng IP của em
  }

  # Outbound - Allow all
  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-web-sg"
  }
}

# ============================================
# SECURITY GROUP cho Database (Private)
# ============================================
resource "aws_security_group" "db" {
  name        = "${var.environment}-db-sg"
  description = "Security group for database servers"
  vpc_id      = aws_vpc.main.id

  # MySQL/MariaDB - Chỉ cho phép từ Web SG
  ingress {
    description     = "MySQL from Web servers"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.web.id] # ← Reference SG khác!
  }

  # SSH từ Web servers (for maintenance)
  ingress {
    description     = "SSH from Web servers"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.web.id]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-db-sg"
  }
}

# ============================================
# DATA SOURCE - Latest Amazon Linux 2023 AMI
# ============================================
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
}

# ============================================
# EC2 - WEB SERVER (Public Subnet)
# ============================================
resource "aws_instance" "web" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.web.id]


  key_name = var.key_pair_name

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              
              # Create simple webpage
              cat > /var/www/html/index.html <<'HTML'
              <!DOCTYPE html>
              <html>
              <head>
                  <title>Web Server</title>
                  <style>
                      body { 
                          font-family: Arial; 
                          background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                          color: white;
                          display: flex;
                          justify-content: center;
                          align-items: center;
                          height: 100vh;
                          margin: 0;
                      }
                      .container {
                          text-align: center;
                          background: rgba(255,255,255,0.1);
                          padding: 50px;
                          border-radius: 20px;
                      }
                  </style>
              </head>
              <body>
                  <div class="container">
                      <h1>🚀 Web Server Running!</h1>
                      <p>Instance ID: $(ec2-metadata --instance-id | cut -d " " -f 2)</p>
                      <p>Private IP: $(ec2-metadata --local-ipv4 | cut -d " " -f 2)</p>
                      <p>Public IP: $(ec2-metadata --public-ipv4 | cut -d " " -f 2)</p>
                      <p>Environment: ${var.environment}</p>
                  </div>
              </body>
              </html>
HTML
              EOF

  tags = {
    Name = "${var.environment}-web-server"
    Role = "WebServer"
  }
}

# ============================================
# EC2 - DATABASE SERVER (Private Subnet)
# ============================================
resource "aws_instance" "db" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.db.id]

  key_name = var.key_pair_name

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y mariadb-server
              systemctl start mariadb
              systemctl enable mariadb
              EOF

  tags = {
    Name = "${var.environment}-db-server"
    Role = "Database"
  }
}