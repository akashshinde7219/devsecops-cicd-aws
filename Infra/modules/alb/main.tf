# modules/alb/main.tf

# Expect var.public_subnets to be a list of subnet IDs (may be produced by module.vpc)
# Use count instead of for_each to avoid "unknown keys at plan time" error.
data "aws_subnet" "selected" {
  count = length(var.public_subnets)
  id    = var.public_subnets[count.index]
}

locals {
  # list of objects with id and az (preserves order by index)
  subnet_infos = [
    for s in data.aws_subnet.selected :
    {
      id = s.id
      az = s.availability_zone
    }
  ]

  # map: availability_zone => subnet_id (one subnet per AZ; later entries override earlier ones)
  az_to_subnet = { for info in local.subnet_infos : info.az => info.id }

  # deterministic ordering: sort AZ names and then build the subnet id list in that AZ order
  az_names_sorted    = sort(keys(local.az_to_subnet))
  alb_subnets_sorted = [ for az in local.az_names_sorted : local.az_to_subnet[az] ]

  # final ALB subnets (one subnet id per AZ)
  alb_subnets = local.alb_subnets_sorted

  # fail early if not enough distinct AZs (ALB requires at least 2)
  _validate_alb_azs = length(local.alb_subnets) >= 2 ? true : (
    fail("ALB requires at least 2 distinct AZ subnets in var.public_subnets. Found ${length(local.alb_subnets)} unique AZ(s). Provide 2+ subnets in different AZs.")
  )
}

resource "aws_lb" "this" {
  name               = "devsecops-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_sg_id]

  # one subnet per AZ (deterministic)
  subnets = local.alb_subnets

  tags = {
    Name = "devsecops-alb"
  }
}

# --- Blue target group ---
resource "aws_lb_target_group" "blue" {
  name        = "devsecops-blue-tg"
  port        = var.blue_target_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = var.target_type == "" ? "instance" : var.target_type

  health_check {
    path                = var.health_check_path != "" ? var.health_check_path : "/health"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    matcher             = "200-399"
  }
}

# Optional: attach instance targets to blue TG if caller passes instance IDs
resource "aws_lb_target_group_attachment" "blue_attach" {
  count            = length(var.target_instance_ids) > 0 ? length(var.target_instance_ids) : 0
  target_group_arn = aws_lb_target_group.blue.arn
  target_id        = var.target_instance_ids[count.index]
  port             = var.blue_target_port
}

# --- Green target group ---
resource "aws_lb_target_group" "green" {
  name        = "devsecops-green-tg"
  port        = var.green_target_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = var.target_type == "" ? "instance" : var.target_type

  health_check {
    path                = var.health_check_path != "" ? var.health_check_path : "/health"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    matcher             = "200-399"
  }
}

resource "aws_lb_target_group_attachment" "green_attach" {
  count            = length(var.target_instance_ids) > 0 ? length(var.target_instance_ids) : 0
  target_group_arn = aws_lb_target_group.green.arn
  target_id        = var.target_instance_ids[count.index]
  port             = var.green_target_port
}

# Listener (default forwards to blue)
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.blue.arn
  }
}


