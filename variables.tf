variable "bucket_name" {
  description = "Globaly unique name for the S3 bucket"
  type        = string
  default     = "asit-demo-bucket-devops"
}

variable "public_key_content" {
  description = "Content of the public SSH key"
}

resource "aws_key_pair" "devops_key" {
  key_name   = "devops-key"
  public_key = var.public_key_content
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

