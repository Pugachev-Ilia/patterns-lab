output "service_name" {
  description = "ECS service name"
  value       = aws_ecs_service.app.name
}

output "service_arn" {
  description = "ECS service ARN"
  value       = aws_ecs_service.app.arn
}

output "task_definition_arn" {
  description = "Task definition ARN"
  value       = aws_ecs_task_definition.app.arn
}

output "service_security_group_id" {
  description = "Security group attached to ECS tasks"
  value       = aws_security_group.service.id
}

output "alb_dns_name" {
  description = "ALB DNS name"
  value       = aws_lb.this.dns_name
}

output "alb_security_group_id" {
  description = "ALB security group ID"
  value       = aws_security_group.alb.id
}

output "target_group_arn" {
  description = "ALB target group ARN"
  value       = aws_lb_target_group.app.arn
}

output "log_group_name" {
  description = "CloudWatch log group name"
  value       = aws_cloudwatch_log_group.this.name
}

output "task_execution_role_arn" {
  description = "IAM task execution role ARN"
  value       = aws_iam_role.task_execution.arn
}

output "task_role_arn" {
  description = "IAM task role ARN"
  value       = aws_iam_role.task.arn
}
