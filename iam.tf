# Create Task Role
resource "aws_iam_role" "main" {
  name = "${var.tenant}_${var.name}_${var.service}_${data.aws_region.current.name}_role_${var.environment}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = {
    Name        = "${var.tenant}_${var.name}_${var.service}_${data.aws_region.current.name}_role_${var.environment}"
    Tenant      = var.tenant
    Project     = var.name
    Environment = var.environment
    Service     = var.service
    Terraform   = "yes"
  }
}

# Loop Additional Task Role Policies
resource "aws_iam_role_policy_attachment" "additional-role-attach" {
  for_each   = toset(var.additional_role_policies)
  role       = aws_iam_role.main.name
  policy_arn = "arn:aws:iam::aws:policy/${each.value}"
}

# Create Role Policy for ECS Task Role
resource "aws_iam_role_policy" "task-role-policy" {
  name = "${var.tenant}_${var.name}_${var.service}_${data.aws_region.current.name}_role_${var.environment}"
  role = aws_iam_role.main.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ssmmessages:CreateControlChannel",
        "ssmmessages:CreateDataChannel",
        "ssmmessages:OpenControlChannel",
        "ssmmessages:OpenDataChannel"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}