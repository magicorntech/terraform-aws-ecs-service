resource "aws_security_group" "main" {
  name        = "${var.tenant}-${var.name}-${var.service}-sg-${var.environment}"
  description = "Managed by Magicorn"
  vpc_id      = var.vpc_id

  ingress {
    protocol    = "tcp"
    from_port   = var.port
    to_port     = var.port
    cidr_blocks = [var.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.tenant}-${var.name}-${var.service}-sg-${var.environment}"
    Tenant      = var.tenant
    Project     = var.name
    Environment = var.environment
    Service     = var.service
    Terraform   = "yes"
  }
}