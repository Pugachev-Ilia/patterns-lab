variable "name" {
  type        = string
  description = "Project name"
}

variable "env" {
  type        = string
  description = "Environment name"
}

variable "cluster_arn" {
  type        = string
  description = "ECS cluster ARN"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "public_subnet_ids" {
  type = list(string)
  description = "Public subnet IDs for ALB"
}

variable "private_subnet_ids" {
  type = list(string)
  description = "Private subnet IDs for Fargate tasks"
}

variable "container_image" {
  type        = string
  description = "Container image (ECR or public)"
}

variable "container_name" {
  type        = string
  description = "Container name in task definition"
  default     = "app"
}

variable "app_port" {
  type        = number
  description = "Container port exposed to ALB"
  default     = 8080
}

variable "health_check_path" {
  type    = string
  description = "ALB target group health check path"
  default = "/"
}

variable "cpu" {
  type        = number
  description = "Task CPU units (256, 512, 1024, ...)"
  default     = 512
}

variable "memory" {
  type        = number
  description = "Task memory (MiB)"
  default     = 1024
}

variable "desired_count" {
  type        = number
  description = "Desired task count"
  default     = 1
}

variable "min_capacity" {
  type        = number
  description = "Autoscaling min tasks"
  default     = 1
}

variable "max_capacity" {
  type        = number
  description = "Autoscaling max tasks"
  default     = 3
}

variable "cpu_target" {
  type        = number
  description = "Target CPU utilization (%)"
  default     = 70
}

variable "log_group_name" {
  type        = string
  description = "CloudWatch log group name (optional override)"
  default     = ""
}

variable "log_retention_days" {
  type        = number
  description = "CloudWatch log retention days"
  default     = 14
}

variable "enable_execute_command" {
  type        = bool
  description = "Enable ECS Exec"
  default     = false
}

variable "environment" {
  type = map(string)
  description = "Container environment variables"
  default = {}
}

variable "tags" {
  type = map(string)
  description = "Common tags"
  default = {}
}
