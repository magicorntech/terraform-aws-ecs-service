resource "aws_ecs_task_definition" "main" {
  family                   = "${var.tenant}-${var.name}-${var.service}-td-${var.environment}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = var.ecs_exec_role
  task_role_arn            = aws_iam_role.main.arn
  cpu                      = var.cpu
  memory                   = var.memory

  container_definitions = <<DEFINITION
[
  {
    "cpu": ${var.cpu},
    "image": "nginx:latest",
    "memory": ${var.memory},
    "name": "${var.service}",
    "networkMode": "awsvpc",
    "volumesFrom": [],
    "mountPoints": [],
    "environment": [],
    "essential": true,
    "portMappings": [
      {
        "containerPort": ${var.port},
        "hostPort": ${var.port},
        "protocol": "tcp"
      }
    ],
    "ulimits": [
      {
        "name": "nofile",
        "softLimit": 64000,
        "hardLimit": 64000
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/ecs/${var.tenant}-${var.name}-${var.service}-svc-${var.environment}",
        "awslogs-region": "${data.aws_region.current.name}",
        "awslogs-stream-prefix": "main",
        "awslogs-create-group": "true"
      }
    },
    "environment" : ${jsonencode(var.parameters)}
  }
]
DEFINITION

  tags = {
    Name        = "${var.tenant}-${var.name}-${var.service}-td-${var.environment}"
    Tenant      = var.tenant
    Project     = var.name
    Environment = var.environment
    Service     = var.service
    Terraform   = "yes"
  }
}

resource "aws_ecs_service" "main" {
  name                              = "${var.tenant}-${var.name}-${var.service}-svc-${var.environment}"
  cluster                           = var.cluster_id
  task_definition                   = aws_ecs_task_definition.main.arn
  desired_count                     = var.desired_count
  platform_version                  = var.platform_version
  enable_execute_command            = true
  health_check_grace_period_seconds = var.hc_grace_period

  deployment_circuit_breaker {
    enable   = var.deploy_circuit_breaker
    rollback = var.deploy_circuit_breaker
  }

  deployment_controller {
    type = "ECS"
  }

  network_configuration {
    security_groups  = [aws_security_group.main.id]
    subnets          = var.pvt_subnet_ids
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.main.id
    container_name   = var.service
    container_port   = var.port
  }
  
  lifecycle {
    ignore_changes = [
      desired_count,
      task_definition,
      capacity_provider_strategy
    ]
  }

  depends_on = [var.alb_https]

  tags = {
    Name        = "${var.tenant}-${var.name}-${var.service}-svc-${var.environment}"
    Tenant      = var.tenant
    Project     = var.name
    Environment = var.environment
    Service     = var.service
    Terraform   = "yes"
  }
}