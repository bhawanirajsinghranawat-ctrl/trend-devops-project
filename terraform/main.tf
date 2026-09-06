terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# -------------------------
# VPC
# -------------------------

resource "aws_vpc" "trend_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "trend-terraform-vpc"
    Environment = "devops-project"
  }
}

# -------------------------
# Internet Gateway
# -------------------------

resource "aws_internet_gateway" "trend_igw" {
  vpc_id = aws_vpc.trend_vpc.id

  tags = {
    Name = "trend-terraform-igw"
  }
}

# -------------------------
# Public Subnet
# -------------------------

resource "aws_subnet" "trend_public_subnet" {
  vpc_id                  = aws_vpc.trend_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = var.aws_availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name        = "trend-terraform-public-subnet"
    Environment = "devops-project"
  }
}

# -------------------------
# Second Public Subnet
# -------------------------

resource "aws_subnet" "trend_public_subnet_b" {
  vpc_id                  = aws_vpc.trend_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = true

  tags = {
    Name        = "trend-terraform-public-subnet-b"
    Environment = "devops-project"
  }
}
# -------------------------
# Public Route Table
# -------------------------

resource "aws_route_table" "trend_public_rt" {
  vpc_id = aws_vpc.trend_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.trend_igw.id
  }

  tags = {
    Name = "trend-terraform-public-route-table"
  }
}

# -------------------------
# Route Table Association
# -------------------------

resource "aws_route_table_association" "trend_public_rta" {
  subnet_id      = aws_subnet.trend_public_subnet.id
  route_table_id = aws_route_table.trend_public_rt.id
}

# -------------------------
# Second Subnet Route Table Association
# -------------------------

resource "aws_route_table_association" "trend_public_rta_b" {
  subnet_id      = aws_subnet.trend_public_subnet_b.id
  route_table_id = aws_route_table.trend_public_rt.id
}

# -------------------------
# Jenkins Security Group
# -------------------------

resource "aws_security_group" "jenkins" {
  name        = "trend-terraform-jenkins-sg"
  description = "Security group for Jenkins server"
  vpc_id      = aws_vpc.trend_vpc.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Jenkins"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "trend-jenkins-sg"
    Environment = "devops-project"
  }
}

# -------------------------
# Jenkins EC2
# -------------------------

resource "aws_instance" "jenkins_ec2" {
  ami           = var.ami_id
  instance_type = "t2.medium"

  subnet_id = aws_subnet.trend_public_subnet.id

  vpc_security_group_ids = [
    aws_security_group.jenkins.id
  ]

  iam_instance_profile = "trend-jenkins-ec2-role"

  key_name = "project2-2"

  associate_public_ip_address = true

  user_data = <<-EOF
    #!/bin/bash

    apt-get update -y

    # Java 21 - required by current Jenkins
    apt-get install -y openjdk-21-jdk

    # Jenkins repository
    wget -O /usr/share/keyrings/jenkins-keyring.asc \
      https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key

    echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
      https://pkg.jenkins.io/debian-stable binary/" \
      > /etc/apt/sources.list.d/jenkins.list

    apt-get update -y

    # Install Jenkins
    apt-get install -y jenkins

    # Start Jenkins
    systemctl enable jenkins
    systemctl start jenkins
  EOF

  tags = {
    Name        = "trend-terraform-jenkins-ec2"
    Environment = "devops-project"
  }
}
