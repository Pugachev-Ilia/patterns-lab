locals {
  base_name = "${var.name}-${var.env}"
  tags = merge(var.tags, { Name = local.base_name })
}

resource "aws_ecs_cluster" "this" {
  name = "${local.base_name}-cluster"

  setting {
    name  = "containerInsights"
    value = var.enable_container_insights ? "enabled" : "disabled"
  }

  tags = merge(local.tags, { Name = "${local.base_name}-ecs-cluster" })
}

resource "aws_ecs_cluster_capacity_providers" "this" {
  cluster_name = aws_ecs_cluster.this.name

  capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight            = 1
    base              = 1
  }
}
