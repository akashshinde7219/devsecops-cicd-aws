variable "vpc_id" {
  type = string
}

variable "private_subnets" {
  type = list(string)
}

variable "instance_type" {
  type = string
}

variable "key_name" {
  type = string
}

variable "app_image" {
  description = "Full ECR image with tag"
  type        = string
}

variable "app_sg_id" {
  type = string
}

variable "blue_target_group_arn" {
  type = string
}

variable "green_target_group_arn" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "account_id" {
  type = string
}

variable "ecr_repo_name" {
  type = string
}
