data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

locals {
  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y docker aws-cli -y
              systemctl enable docker
              systemctl start docker

              REGISTRY="${var.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com"

              aws ecr get-login-password --region ${var.aws_region} | \
                docker login --username AWS --password-stdin $REGISTRY

              docker pull ${var.app_image}
              docker run -d -p 5000:5000 --name flask-app ${var.app_image}
              EOF
}

# BLUE EC2
resource "aws_instance" "blue" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  subnet_id              = var.private_subnets[0]
  vpc_security_group_ids = [var.app_sg_id]
  key_name               = var.key_name
  user_data              = local.user_data

  tags = {
    Name        = "devsecops-blue"
    Environment = "blue"
  }
}

resource "aws_lb_target_group_attachment" "blue_attachment" {
  target_group_arn = var.blue_target_group_arn
  target_id        = aws_instance.blue.id
  port             = 5000
}

# GREEN EC2
resource "aws_instance" "green" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  subnet_id              = var.private_subnets[1]
  vpc_security_group_ids = [var.app_sg_id]
  key_name               = var.key_name
  user_data              = local.user_data

  tags = {
    Name        = "devsecops-green"
    Environment = "green"
  }
}

resource "aws_lb_target_group_attachment" "green_attachment" {
  target_group_arn = var.green_target_group_arn
  target_id        = aws_instance.green.id
  port             = 5000
}
