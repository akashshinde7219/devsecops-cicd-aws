🚀 DevSecOps CI/CD Pipeline on AWS

Terraform · Jenkins · Docker · ECR · ALB Blue-Green · Trivy

📁 Project Structure

devsecops-cicd-aws/
│
├── app/                     # Flask application
│   ├── app.py
│   ├── Dockerfile
│   ├── requirements.txt
│   └── tests/
│
├── infra/                   # Terraform IaC
│   ├── modules/
│   │   ├── vpc/
│   │   ├── alb/
│   │   └── ec2/
│   └── main.tf
│
├── jenkins/
│   └── Jenkinsfile
│
└── README.md


📌 Project Overview

This project demonstrates a real-world DevSecOps CI/CD pipeline for deploying a Flask web application on AWS using Infrastructure as Code, containerization, automated security scans, and Blue-Green deployment for zero-downtime releases.

The pipeline automates everything from code commit to production traffic switch, following DevOps and security best practices.

🛠️ Tech Stack

CI/CD: Jenkins (Declarative Pipeline)

Containerization: Docker

Container Registry: AWS ECR

Infrastructure as Code: Terraform

Cloud: AWS (VPC, EC2, ALB, Security Groups)

Deployment Strategy: Blue-Green Deployment (ALB Target Groups)

Security: Trivy (Container Image Vulnerability Scanning)

Application: Python Flask

Testing: Pytest

🔄 CI/CD Pipeline Flow

![alt text](image.png)

Code Push

Developer pushes code to GitHub

Jenkins Pipeline Execution

Source code checkout

Unit testing using pytest

Docker image build

Security scan of Docker image using Trivy

Push Docker image to AWS ECR

Infrastructure Provisioning (Terraform)

VPC, Subnets, Internet Gateway

Application Load Balancer (ALB)

Blue & Green Target Groups

EC2 instances for Blue and Green environments

Security Groups and networking

Blue-Green Deployment

Application deployed to Green environment

Health checks via ALB

Traffic switched from Blue → Green with zero downtime

🧱 Architecture Overview

ALB routes traffic to either Blue or Green target group

Terraform manages infrastructure state and updates

Dockerized Flask app runs on EC2 instances

Trivy ensures container images are free from critical vulnerabilities before deployment

🔐 Security Implementation

Trivy Image Scanning

Scans Docker images for OS and library vulnerabilities

Pipeline fails if critical vulnerabilities are detected

AWS Security Groups

Least-privilege access

Only required ports exposed (80, 443, 22)