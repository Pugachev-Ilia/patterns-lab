# Common
variable "aws_region" {
  type = string
}

variable "name" {
  type = string
}

variable "env" {
  type = string
}

# VPC
variable "vpc_cidr" {
  type = string
}

variable "public_subnet_cidrs" {
  type = list(string)
  description = "Must match the number of AZs used (>=2)"
}

variable "private_subnet_cidrs" {
  type = list(string)
  description = "Must match the number of AZs used (>=2)"
}

variable "enable_nat_gateway" {
  type    = bool
  default = true
}

variable "single_nat_gateway" {
  type    = bool
  default = true
}

# ECR
variable "ecr_scan_on_push" {
  type    = bool
  default = true
}

variable "ecr_keep_last_images" {
  type    = number
  default = 20
}

# EKS Cluster
variable "enable_container_insights" {
  type    = bool
  default = true
}

# ECS Service
variable "container_image" {
  type        = string
  description = "Image for ECS task (ECR URL with tag)"
}

variable "app_port" {
  type    = number
  default = 8080
}

variable "ecs_cpu" {
  type    = number
  default = 512
}

variable "ecs_memory" {
  type    = number
  default = 1024
}

variable "desired_count" {
  type    = number
  default = 0
}

variable "enable_execute_command" {
  type    = bool
  default = false
}

variable "container_environment" {
  type = map(string)
  default = {}
}

variable "alb_health_check_path" {
  type    = string
  default = "/"
}

variable "log_retention_days" {
  type    = number
  default = 14
}
