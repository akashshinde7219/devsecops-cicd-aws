# DevSecOps CI/CD on AWS with Terraform, Blue-Green & Security Scans

This project demonstrates an end-to-end DevSecOps CI/CD pipeline for a Flask web application using:

- Jenkins (Declarative Pipeline)
- Docker & AWS ECR
- Terraform (VPC, EC2, ALB, Security Groups)
- Blue-Green deployment using ALB Target Groups
- SonarQube for code quality
- Trivy for container image vulnerability scanning

## High-Level Flow

1. Developer pushes code → GitHub
2. Jenkins pipeline triggers:
   - Checkout
   - SonarQube code scan
   - Unit tests (pytest)
   - Docker build
   - Trivy image scan
   - Push image to AWS ECR
3. Terraform provisions/updates AWS infra:
   - VPC, subnets, IGW
   - ALB + Blue/Green Target Groups
   - EC2 instances (Blue + Green)
4. Application deployed to Green, health-checked, then traffic switched via ALB.

## Run Locally

```bash
cd app
pip install -r requirements.txt
python app.py
# visit http://localhost:5000
