# Terraform + Ansible AWS Demo – EC2 with Docker and Nginx

This project demonstrates a **complete Infrastructure as Code (IaC) workflow** using:

- **Terraform** – to provision AWS resources (EC2, Security Group, S3 bucket, SSH access)
- **Ansible** – to configure the EC2 instance (install Docker and deploy an Nginx container)

---

## Prerequisites

- AWS CLI installed and configured (`aws configure`)
- Terraform v1.x installed
- Ansible installed
- Community Docker collection installed

```bash
 ansible-galaxy collection install community.docker
```

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

   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

   ```bash
   # Edit terraform.tfvars and set:
   # bucket_name = "your-unique-bucket-name"
   # public_key_path = "/absolute/path/to/your-key.pub"
   # instance_type = "t3.micro"
   ```

3. ### Deploy infrastructure

   ```bash
   terraform init
   ```

   Plan and apply changes

   ```bash
   terraform apply -auto-approve
   ```

4. ### Configure server with Ansible

   ```bash
   ansible-playbook -i ansible/inventory.ini ansible/install-docker-nginx.yml
   ```

5. ### Connect to the EC2 instance via SSH

   ```bash
   ssh -i /path/to/private-key.pem ubuntu@<EC2_PUBLIC_IP>
   ```

   To get public IP of EC2, type:

   ```bash
   terraform output -raw ec2_public_ip
   ```

6. ### Test Nginx
   Access the Nginx server from your browser:
   ```bash
   http://<EC2_PUBLIC_IP>
   ```
   or from CLI:
   ```bash
   curl http://$(terraform output -raw ec2_public_ip)
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
