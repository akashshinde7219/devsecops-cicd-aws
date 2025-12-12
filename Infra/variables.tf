variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "app_image" {
  description = "Full ECR image with tag"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "EC2 key pair name"
  type        = string
  default = "devops-project.pem"
}

variable "aws_account_id" {
  description = "AWS Account ID"
  type        = string
  default = "730335595521"
}

variable "ecr_repo_name" {
  description = "ECR repo name"
  type        = string
  default = "730335595521.dkr.ecr.ap-south-1.amazonaws.com/devsecops"
}
