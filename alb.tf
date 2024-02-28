resource "aws_alb_target_group" "main" {
  name                 = "${var.tenant}-${var.name}-${var.service}-tg-${var.environment}"
  port                 = var.port
  protocol             = "HTTP"
  vpc_id               = var.vpc_id
  target_type          = "ip"
  deregistration_delay = var.deregistration_delay

  health_check {
    path                = var.healthcheck_path
    interval            = var.healthcheck_interval
    timeout             = var.healthcheck_timeout
    healthy_threshold   = var.healthcheck_pos_threshold
    unhealthy_threshold = var.healthcheck_neg_threshold
  }

  tags = {
    Name        = "${var.tenant}-${var.name}-${var.service}-tg-${var.environment}"
    Tenant      = var.tenant
    Project     = var.name
    Environment = var.environment
    Service     = var.service
    Terraform   = "yes"
  }
}

resource "aws_lb_listener_rule" "main" {
  listener_arn = var.alb_https
  priority     = var.predencence

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.main.arn
  }

  condition {
    host_header {
      values = [var.deploy_url]
    }
  }
}