# ECR
output "ecr_repository_url" {
  value = module.ecr.repository_url
}

# ALB
output "alb_dns_name" {
  value = module.ecs_service.alb_dns_name
}
