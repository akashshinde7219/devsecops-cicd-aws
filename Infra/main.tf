provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source = "./modules/vpc"

  vpc_cidr_block = "10.0.0.0/16"
}

module "security_groups" {
  source = "./modules/security_groups"

  vpc_id = module.vpc.vpc_id
}

module "alb" {
  source = "./modules/alb"

  vpc_id             = module.vpc.vpc_id
  public_subnets     = module.vpc.public_subnets
  alb_sg_id          = module.security_groups.alb_sg_id
  blue_target_port   = 5000
  green_target_port  = 5000
}

module "ec2_blue_green" {
  source = "./modules/ec2_blue_green"

  vpc_id          = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnets

  instance_type   = var.instance_type
  key_name        = var.key_name

  app_image       = var.app_image
  app_sg_id       = module.security_groups.app_sg_id

  blue_target_group_arn  = module.alb.blue_tg_arn
  green_target_group_arn = module.alb.green_tg_arn

  aws_region      = var.aws_region          # ✨ new
  account_id      = var.aws_account_id      # ✨ new
  ecr_repo_name   = var.ecr_repo_name       # ✨ new
}

