# ECR
output "ecr_repository_url" {
  value = module.ecr.repository_url
}

# ALB
output "alb_dns_name" {
  value = module.ecs_service.alb_dns_name
}

# ECS identifiers (for CI/CD)
output "ecs_cluster_name" {
  value = module.ecs_cluster.cluster_name
}

output "ecs_service_name" {
  value = module.ecs_service.service_name
}

output "ecs_container_name" {
  value = "app"
}
