terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# Get default VPC
data "aws_vpc" "default" {
  default = true
}

# Create S3 Bucket
resource "aws_s3_bucket" "demo_bucket" {
  bucket = var.bucket_name
  tags = {
    Name        = "DemoBucket"
    Environment = "Dev"
  }
}


# Security Group for SSH and HTTP 
resource "aws_security_group" "demo_sg" {
  name        = "demo-sg"
  description = "Allow SSH and HTTP inbound traffic"
  vpc_id      = data.aws_vpc.default.id
  # SSH
  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP
  ingress {
    description = "HTTP from anywhere"
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
    Name = "demo-sg"
  }
}


# SSH key 
resource "aws_key_pair" "devops_key" {
  key_name   = "devops-key"
  public_key = var.public_key_content
}


# EC2 Instance
resource "aws_instance" "demo_instance" {
  ami                    = "ami-0a7d80731ae1b2435" # Ubuntu 22.04 LTS (us-east-1)
  instance_type          = var.instance_type
  key_name               = aws_key_pair.devops_key.key_name
  vpc_security_group_ids = [aws_security_group.demo_sg.id]

  tags = {
    Name = "demo-ubuntu-docker-nginx"
  }

  depends_on = [aws_key_pair.devops_key]
}

resource "local_file" "ansible_inventory" {
  filename = "${path.module}/ansible/inventory.ini"
  content  = <<EOT
  [webserver]
    ${aws_instance.demo_instance.public_ip} ansible_ssh_private_key_file=~/.ssh/devops-key ansible_user=ubuntu
  EOT
}

terraform {
  backend "s3" {
    bucket = "my-devops-demo-terraform-state"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}

