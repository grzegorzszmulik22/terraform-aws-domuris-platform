resource "aws_cloudwatch_log_group" "this" {
  name              = "/ecs/${var.name}"
  retention_in_days = 30
  tags              = var.tags
}

resource "aws_iam_role" "execution" {
  name               = "${var.name}-execution"
  assume_role_policy = data.aws_iam_policy_document.task_assume.json
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "execution" {
  role       = aws_iam_role.execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ECS reads container secrets with the execution role, not the task role, so
# the execution role needs read access to exactly the injected secrets (and
# their customer-managed KMS keys, if any).
data "aws_iam_policy_document" "execution_secrets" {
  count = length(var.secret_arns) == 0 ? 0 : 1

  statement {
    sid       = "ReadInjectedSecrets"
    actions   = ["secretsmanager:GetSecretValue"]
    resources = distinct(values(var.secret_arns))
  }

  dynamic "statement" {
    for_each = length(var.secret_kms_key_arns) == 0 ? [] : [1]
    content {
      sid       = "DecryptInjectedSecrets"
      actions   = ["kms:Decrypt"]
      resources = var.secret_kms_key_arns
    }
  }
}

resource "aws_iam_role_policy" "execution_secrets" {
  count = length(var.secret_arns) == 0 ? 0 : 1

  name   = "${var.name}-execution-secrets"
  role   = aws_iam_role.execution.id
  policy = data.aws_iam_policy_document.execution_secrets[0].json
}

resource "aws_iam_role" "task" {
  name               = "${var.name}-task"
  assume_role_policy = data.aws_iam_policy_document.task_assume.json
  tags               = var.tags
}

resource "aws_iam_role_policy" "task" {
  count = var.task_policy_json == null ? 0 : 1

  name   = "${var.name}-task"
  role   = aws_iam_role.task.id
  policy = var.task_policy_json
}

resource "aws_security_group" "service" {
  name        = "${var.name}-service"
  description = "API service ingress from ALB"
  vpc_id      = var.vpc_id

  ingress {
    description     = "ALB to API"
    from_port       = var.container_port
    to_port         = var.container_port
    protocol        = "tcp"
    security_groups = [var.alb_security_group_id]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

resource "aws_ecs_task_definition" "this" {
  family                   = var.name
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = aws_iam_role.execution.arn
  task_role_arn            = aws_iam_role.task.arn

  container_definitions = jsonencode([
    {
      name      = "api"
      image     = var.container_image
      essential = true

      portMappings = [
        {
          containerPort = var.container_port
          protocol      = "tcp"
        }
      ]

      environment = local.environment
      secrets     = local.secrets

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.this.name
          awslogs-region        = data.aws_region.current.region
          awslogs-stream-prefix = "api"
        }
      }
    }
  ])

  tags = var.tags
}

resource "aws_ecs_service" "this" {
  name            = var.name
  cluster         = var.cluster_arn
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200
  enable_execute_command             = false

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = concat([aws_security_group.service.id], var.additional_security_group_ids)
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = "api"
    container_port   = var.container_port
  }

  tags = var.tags
}
