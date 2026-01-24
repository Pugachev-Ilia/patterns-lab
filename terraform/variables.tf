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
