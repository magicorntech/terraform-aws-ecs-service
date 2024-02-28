# terraform-aws-ecs-service

Magicorn made Terraform Module for AWS Provider
--
```
module "ecs-service" {
  source         = "magicorntech/ecs-service/aws"
  version        = "0.0.1"
  tenant         = var.tenant
  name           = var.name
  environment    = var.environment
  vpc_id         = var.vpc_id
  cidr_block     = var.cidr_block
  pvt_subnet_ids = var.pvt_subnet_ids
  alb_dns_name   = var.alb_dns_name
  alb_zone_id    = var.alb_zone_id
  alb_https      = var.alb_https
  hosted_zone    = var.hosted_zone
  ecs_exec_role  = var.ecs_exec_role
  cluster_id     = var.cluster_id
  cluster_arn    = var.cluster_arn
  cluster_name   = var.cluster_name

  # ECS Service Configuration
  service                   = "backend"
  autoscaling               = false
  cpu                       = 512
  memory                    = 1024
  port                      = 8080
  parameters                = [
    {"name": "ENV1", "value": "hello"},
    {"name": "ENV2", "value": "world"}
  ]
  desired_count             = 1
  hc_grace_period           = 15
  deploy_circuit_breaker    = true
  platform_version          = "1.4.0"
  deploy_url                = "api.subdomain.example.net" # must reside at route53
  predencence               = 101 # also important for load balancer evaluation rule count
  deregistration_delay      = 60
  healthcheck_path          = "/healthz"
  healthcheck_interval      = 30
  healthcheck_timeout       = 5
  healthcheck_pos_threshold = 2
  healthcheck_neg_threshold = 3
  additional_role_policies  = ["AmazonWorkMailReadOnlyAccess"]
}
```

## Notes
1) Works with Fargate only.
2) Works better with ALB module.