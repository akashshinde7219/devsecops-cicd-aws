output "alb_dns_name" {
  value = aws_lb.this.dns_name
}

output "blue_tg_arn" {
  value = aws_lb_target_group.blue.arn
}

output "green_tg_arn" {
  value = aws_lb_target_group.green.arn
}

output "computed_alb_subnets" {
  value = local.alb_subnets
  description = "List of subnet IDs chosen (one per AZ) for the ALB"
}

output "computed_subnet_az_map" {
  value = {
    for id, s in data.aws_subnet.selected :
    id => s.availability_zone
  }
  description = "Map of provided subnet_id => availability_zone"
}
