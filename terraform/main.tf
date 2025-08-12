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

# Create S3 Bucket for Terraform state
resource "aws_s3_bucket" "terraform_state" {
  bucket = "bucket-name" # Update bucket name 

  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Hardening S3 bucket's security 
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

# DynamoDB for Terraform state
resource "aws_dynamodb_table" "terraform_state" {
  name         = "terraform-state"
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

# Backend S3 for Terraform
terraform {
  backend "s3" {
    bucket         = "bucket-name" # Update this name
    key            = "folder_path/terraform.tfstate" # Provide correct path in S3
    region         = "us-east-1"
    dynamodb_table = "terraform-state"
    encrypt        = true
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
  public_key = file("path") # Provide path to public key
}


# EC2 Instance
resource "aws_instance" "demo_instance" {
  ami                    = "ami-0a7d80731ae1b2435" # Ubuntu 22.04 LTS (us-east-1)
  instance_type          = "t3.micro"
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

