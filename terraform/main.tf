terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}


terraform {
  backend "s3" {}
}

provider "aws" {
  region = var.aws_region
}

data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  azs = slice(data.aws_availability_zones.available.names, 0, 2)
  tags = {
    Project     = var.name
    Environment = var.env
    ManagedBy   = "terraform"
  }
}

module "vpc" {
  source = "./modules/vpc"

  name = var.name
  env  = var.env

  vpc_cidr = var.vpc_cidr
  azs      = local.azs

  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs

  enable_nat_gateway = var.enable_nat_gateway
  single_nat_gateway = var.single_nat_gateway

  tags = local.tags
}

module "ecr" {
  source = "./modules/ecr"

  name = "${var.name}-${var.env}"
  tags = local.tags

  scan_on_push     = var.ecr_scan_on_push
  keep_last_images = var.ecr_keep_last_images
}

module "ecs_cluster" {
  source = "./modules/ecs_cluster"

  name = var.name
  env  = var.env

  enable_container_insights = var.enable_container_insights
  tags                      = local.tags
}

module "ecs_service" {
  source = "./modules/ecs_service"

  name = var.name
  env  = var.env
  tags = local.tags

  cluster_arn = module.ecs_cluster.cluster_arn

  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids

  container_image   = var.container_image
  container_name    = "app"
  app_port          = var.app_port
  health_check_path = var.alb_health_check_path

  cpu    = var.ecs_cpu
  memory = var.ecs_memory

  desired_count = var.desired_count

  min_capacity = 1
  max_capacity = 3
  cpu_target   = 70

  log_retention_days = var.log_retention_days

  enable_execute_command = var.enable_execute_command
  environment            = var.container_environment
}
