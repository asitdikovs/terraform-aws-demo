# Terraform AWS Demo – EC2 with Docker and Nginx

This Terraform project demonstrates how to provision basic AWS infrastructure:

- An S3 bucket
- A security group allowing SSH and HTTP access
- An EC2 instance running Ubuntu 22.04
- Automatic installation of Docker and deployment of an Nginx container on instance boot

---

## Prerequisites

- AWS CLI installed and configured (`aws configure`)
- Terraform v1.x installed
- A valid AWS account with permissions to create EC2, S3, and networking resources
- An existing SSH key pair on your local machine (e.g., `~/.ssh/devops-key.pub`)

---

## Usage

1. ### **Clone the repository**
   ```bash
   git clone https://github.com/asitdikovs/terraform-aws-demo.git
   cd terraform-aws-demo
   ```
2. ### Copy and edit variables file

   cp terraform.tfvars.example terraform.tfvars

   #Edit terraform.tfvars and set:
   #bucket_name = "your-unique-bucket-name"
   #public_key_path = "/absolute/path/to/your-key.pub"
   #instance_type = "t3.micro"

3. ### Initialize Terraform

   ```bash
   terraform init
   ```

   Plan and apply changes

   ```bash
   terraform plan
   terraform apply -auto-approve
   ```

4. ### Get EC2 public IP

   ```bash
   terraform output ec2_public_ip
   ```

5. ### Connect to the EC2 instance via SSH
   ```bash
   ssh -i /path/to/private-key.pem ubuntu@<EC2_PUBLIC_IP>
   ```
   Or access the Nginx server from your browser:
   ```bash
   http://<EC2_PUBLIC_IP>
   ```

## Cleanup

To avoid ongoing AWS charges, destroy all resources when you're done:

```bash
terraform destroy -auto-approve
```

## Notes

- The S3 bucket name must be unique across all AWS accounts worldwide.

- Update the AMI ID in main.tf if you deploy in a region other than us-east-1.

- This example is for learning and demonstration purposes only.
