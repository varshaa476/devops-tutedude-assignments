# Assignment 8 - Part 3: Flask & Express on ECR/ECS/VPC

Deploys the Flask backend and Express frontend as Docker containers on AWS
ECS Fargate, behind an Application Load Balancer, inside a custom VPC.

## Infrastructure (via Terraform)
- Custom VPC with 2 public subnets across 2 AZs
- Internet Gateway + route table
- ECR repositories for both images
- ECS Fargate cluster with 2 services (flask, express)
- Application Load Balancer:
  - Port 80 -> Express frontend (default)
  - Port 5000 -> Flask backend (direct API access)
- CloudWatch log groups for both services
- IAM execution role for ECS tasks

## Deploy
terraform init
terraform apply


Build and push both images to the ECR repos output by Terraform, then
force a new ECS deployment to pick them up. See main.tf for full details.

## Live URL (while running)
http://assignment8-alb-1562368041.ap-southeast-2.elb.amazonaws.com
