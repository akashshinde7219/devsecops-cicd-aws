variable "public_subnets" {
  type = list(string)
}

variable "alb_sg_id" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "blue_target_port" {
  type = number
  default = 80
}

variable "green_target_port" {
  type = number
  default = 80
}

# optional: pass instance IDs to auto-attach targets (set to [] to skip)
variable "target_instance_ids" {
  type    = list(string)
  default = []
}

# optional: "instance" (default) or "ip"
variable "target_type" {
  type    = string
  default = "instance"
}

# optional override for health check path (defaults to /health)
variable "health_check_path" {
  type    = string
  default = "/health"
}
