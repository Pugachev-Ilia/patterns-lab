# VPC
output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_ids" {
  value = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.vpc.private_subnet_ids
}

# ECR
output "ecr_repository_url" {
  value = module.ecr.repository_url
}

# ALB
output "alb_dns_name" {
  value = module.ecs_service.alb_dns_name
}

# EKS Cluster
output "ecs_cluster_name" {
  value = module.ecs_cluster.cluster_name
}

output "ecs_cluster_arn" {
  value = module.ecs_cluster.cluster_arn
}

# ECS Service
output "ecs_service_name" {
  value = module.ecs_service.service_name
}

output "ecs_service_arn" {
  value = module.ecs_service.service_arn
}
