# Common
aws_region = "eu-central-1"
name       = "patterns-lab"
env = "develop"

# VPC
vpc_cidr = "10.20.0.0/16"

public_subnet_cidrs = ["10.20.0.0/24", "10.20.1.0/24"]
private_subnet_cidrs = ["10.20.10.0/24", "10.20.11.0/24"]

enable_nat_gateway = true
single_nat_gateway = true

# ECR
ecr_scan_on_push = true
ecr_keep_last_images = 20

# ECS Service
container_image = "590183999008.dkr.ecr.eu-central-1.amazonaws.com/patterns-lab-develop:latest"
app_port        = 8080

ecs_cpu = 256
ecs_memory = 512

# To prevent ECS tasks without an image from being rolled out during infrastructure rollout
desired_count = 0

log_retention_days = 14

container_environment = {
  PORT = "8080"
}
