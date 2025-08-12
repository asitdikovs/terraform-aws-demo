# Terraform + Ansible AWS Demo

This project demonstrates a complete Infrastructure as Code (IaC) workflow using Terraform and Ansible to provision and configure AWS resources.

## Project Structure

- `terraform/main.tf`: Provisions AWS resources (EC2, Security Group, S3 bucket) and configures state storage with versioning and encryption.
- `terraform/output.tf`: Outputs the EC2 public IP and S3 bucket name.
- `ansible/playbook.yml`: Installs Docker, starts the Docker service, and deploys an Nginx container on the EC2 instance.

## Prerequisites

- AWS CLI installed and configured (`aws configure`)
- Terraform v1.x installed
- Ansible installed
- Community Docker collection installed:
  ```bash
  ansible-galaxy collection install community.docker
  ```
- Valid AWS account with permissions
- Existing SSH key pair on your local machine

## Usage

1. **Clone the repository**
   ```bash
   git clone https://github.com/asitdikovs/terraform-aws-demo.git
   cd terraform-aws-demo
   ```
2. **Copy and edit variables file**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars as needed
   ```
3. **Deploy infrastructure**
   ```bash
   terraform init
   terraform apply -auto-approve
   ```
4. **Configure server with Ansible**
   ```bash
   ansible-playbook -i ansible/inventory.ini ansible/playbook.yml
   ```
5. **Connect to EC2 via SSH**
   ```bash
   ssh -i /path/to/private-key.pem ubuntu@<EC2_PUBLIC_IP>
   terraform output -raw ec2_public_ip
   ```
6. **Test Nginx**
   ```bash
   curl http://$(terraform output -raw ec2_public_ip)
   ```

## Cleanup

Destroy all resources to avoid AWS charges:
```bash
terraform destroy -auto-approve
```


## Required Changes in `main.tf`

Before deploying, update the following in `terraform/main.tf`:

- **S3 bucket name**: Replace `"bucket-name"` with a globally unique name in both the `aws_s3_bucket` resource and the backend configuration.
- **S3 backend key**: Update `key = "folder_path/terraform.tfstate"` to your desired path in the S3 bucket.
- **Public key path**: In `aws_key_pair`, change `file("path")` to the absolute path of your public SSH key (e.g., `~/.ssh/devops-key.pub`).
- **AMI ID**: If deploying outside `us-east-1`, update the `ami` value to a valid Ubuntu 22.04 LTS AMI for your region.

## Notes

- For demonstration and learning purposes only.
