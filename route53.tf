resource "aws_route53_record" "main" {
  zone_id = var.hosted_zone
  name    = var.deploy_url
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}