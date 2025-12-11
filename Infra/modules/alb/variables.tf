variable "vpc_id" {
  type = string
}

variable "public_subnets" {
  type = list(string)
}

variable "alb_sg_id" {
  type = string
}

variable "blue_target_port" {
  type = number
}

variable "green_target_port" {
  type = number
}
