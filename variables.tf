variable "bucket_name" {
  description = "Globaly unique name for the S3 bucket"
  type        = string
  default     = "asit-demo-bucket-devops"
}

variable "public_key_path" {
  description = "Path to the public SSH key"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

