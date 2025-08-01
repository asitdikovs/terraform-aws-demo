variable "bucket_name" {
  description = "Globaly unique name for the S3 bucket"
  type        = string
  default     = "asit-demo-bucket-devops"
}

variable "public_key_content" {
  description = "Content of the public SSH key"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

