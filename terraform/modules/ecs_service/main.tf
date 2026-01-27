# To make the module easy to integrate, it was decided to combine ALB, CloudWatch Logs, IAM roles, and ECS service resources into a single module.
# For the current level of reusability, this is the best solution.
# While placing each component in a separate module would provide greater flexibility, it would increase the complexity of integration and debugging.
locals {
  base_name = "${var.name}-${var.env}"
  tags = merge(var.tags, { Name = local.base_name })

  container_env = [
    for k, v in var.environment : { name = k, value = v }
  ]
}

data "aws_region" "current" {}


# ALB
resource "aws_security_group" "alb" {
  name   = "${local.base_name}-alb-sg"
  vpc_id = var.vpc_id

  ingress {
    description = "HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description = "HTTPS from internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    description = "Outbound to targets"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(local.tags, { Name = "${local.base_name}-alb-sg" })
}

resource "aws_lb" "this" {
  name               = "${local.base_name}-alb"
  load_balancer_type = "application"
  subnets            = var.public_subnet_ids
  security_groups = [aws_security_group.alb.id]

  tags = merge(local.tags, { Name = "${local.base_name}-alb" })
}

resource "aws_lb_target_group" "app" {
  name        = "${local.base_name}-tg"
  port        = var.app_port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    path                = var.health_check_path
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = merge(local.tags, { Name = "${local.base_name}-tg" })
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

# CloudWatch Logs for ECS service
resource "aws_cloudwatch_log_group" "this" {
  name              = var.log_group_name != "" ? var.log_group_name : "/ecs/${local.base_name}"
  retention_in_days = var.log_retention_days
  tags = merge(local.tags, { Name = "${local.base_name}-logs" })
}

# IAM for ECS service
data "aws_iam_policy_document" "ecs_task_assume_role" {
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "task_execution" {
  name               = "${local.base_name}-ecs-task-execution"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json
  tags = merge(local.tags, { Name = "${local.base_name}-ecs-task-execution" })
}

resource "aws_iam_role_policy_attachment" "task_execution" {
  role       = aws_iam_role.task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "task" {
  name               = "${local.base_name}-ecs-task"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json
  tags = merge(local.tags, { Name = "${local.base_name}-ecs-task" })
}

# ECS service
resource "aws_security_group" "service" {
  name   = "${local.base_name}-ecs-sg"
  vpc_id = var.vpc_id

  ingress {
    description = "App traffic from ALB only"
    from_port   = var.app_port
    to_port     = var.app_port
    protocol    = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    description = "Outbound to internet via NAT (private subnets)"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags, { Name = "${local.base_name}-ecs-sg" })
}

resource "aws_ecs_task_definition" "app" {
  family       = local.base_name
  requires_compatibilities = ["FARGATE"]
  network_mode = "awsvpc"
  cpu = tostring(var.cpu)
  memory = tostring(var.memory)

  execution_role_arn = aws_iam_role.task_execution.arn
  task_role_arn      = aws_iam_role.task.arn

  container_definitions = jsonencode([
    {
      name      = var.container_name
      image     = var.container_image
      essential = true

      portMappings = [
        { containerPort = var.app_port, protocol = "tcp" }
      ]

      environment = local.container_env

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.this.name
          awslogs-region        = data.aws_region.current.id
          awslogs-stream-prefix = var.container_name
        }
      }
    }
  ])

  tags = merge(local.tags, { Name = "${local.base_name}-taskdef" })
}

resource "aws_ecs_service" "app" {
  name            = "${local.base_name}-svc"
  cluster         = var.cluster_arn
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = var.desired_count

  launch_type = "FARGATE"

  enable_execute_command = var.enable_execute_command
  health_check_grace_period_seconds = var.health_check_grace_period_seconds

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups = [aws_security_group.service.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.app.arn
    container_name   = var.container_name
    container_port   = var.app_port
  }

  # Designed to enable infrastructure updates without affecting raised ECS tasks
  lifecycle {
    ignore_changes = [desired_count]
  }

  tags = merge(local.tags, { Name = "${local.base_name}-service" })
}

resource "aws_appautoscaling_target" "ecs" {
  min_capacity       = var.min_capacity
  max_capacity       = var.max_capacity
  resource_id        = "service/${split("/", var.cluster_arn)[1]}/${aws_ecs_service.app.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "cpu" {
  name               = "${local.base_name}-cpu"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = var.cpu_target
    scale_in_cooldown  = 60
    scale_out_cooldown = 60
  }
}
