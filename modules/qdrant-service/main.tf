resource "aws_cloudwatch_log_group" "this" {
  name              = "/ecs/${var.name}"
  retention_in_days = 30
  tags              = var.tags
}

data "aws_region" "current" {}

resource "aws_security_group" "qdrant" {
  name        = "${var.name}-qdrant"
  description = "Internal Qdrant service"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = toset(var.allowed_security_group_ids)

    content {
      description     = "Qdrant HTTP from application services"
      from_port       = 6333
      to_port         = 6333
      protocol        = "tcp"
      security_groups = [ingress.value]
    }
  }

  dynamic "ingress" {
    for_each = toset(var.allowed_security_group_ids)

    content {
      description     = "Qdrant gRPC from application services"
      from_port       = 6334
      to_port         = 6334
      protocol        = "tcp"
      security_groups = [ingress.value]
    }
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.name}-qdrant"
  })
}

resource "aws_security_group" "efs" {
  name        = "${var.name}-qdrant-efs"
  description = "Qdrant EFS ingress"
  vpc_id      = var.vpc_id

  ingress {
    description     = "NFS from Qdrant tasks"
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [aws_security_group.qdrant.id]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.name}-qdrant-efs"
  })
}

resource "aws_efs_file_system" "this" {
  encrypted  = true
  kms_key_id = var.kms_key_id

  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }

  tags = merge(var.tags, {
    Name = "${var.name}-qdrant"
  })
}

resource "aws_efs_mount_target" "this" {
  for_each = toset(var.private_subnet_ids)

  file_system_id  = aws_efs_file_system.this.id
  subnet_id       = each.value
  security_groups = [aws_security_group.efs.id]
}

resource "aws_efs_access_point" "qdrant" {
  file_system_id = aws_efs_file_system.this.id

  posix_user {
    gid = 1000
    uid = 1000
  }

  root_directory {
    path = "/qdrant"

    creation_info {
      owner_gid   = 1000
      owner_uid   = 1000
      permissions = "0750"
    }
  }

  tags = merge(var.tags, {
    Name = "${var.name}-qdrant"
  })
}

data "aws_iam_policy_document" "task_assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "execution" {
  name               = "${var.name}-qdrant-execution"
  assume_role_policy = data.aws_iam_policy_document.task_assume.json
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "execution" {
  role       = aws_iam_role.execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "task" {
  name               = "${var.name}-qdrant-task"
  assume_role_policy = data.aws_iam_policy_document.task_assume.json
  tags               = var.tags
}

resource "aws_ecs_task_definition" "this" {
  family                   = "${var.name}-qdrant"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = aws_iam_role.execution.arn
  task_role_arn            = aws_iam_role.task.arn

  volume {
    name = "qdrant-storage"

    efs_volume_configuration {
      file_system_id     = aws_efs_file_system.this.id
      transit_encryption = "ENABLED"

      authorization_config {
        access_point_id = aws_efs_access_point.qdrant.id
        iam             = "DISABLED"
      }
    }
  }

  container_definitions = jsonencode([
    {
      name      = "qdrant"
      image     = var.container_image
      essential = true

      portMappings = [
        {
          containerPort = 6333
          protocol      = "tcp"
        },
        {
          containerPort = 6334
          protocol      = "tcp"
        }
      ]

      mountPoints = [
        {
          sourceVolume  = "qdrant-storage"
          containerPath = "/qdrant/storage"
          readOnly      = false
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.this.name
          awslogs-region        = data.aws_region.current.region
          awslogs-stream-prefix = "qdrant"
        }
      }
    }
  ])

  tags = var.tags
}

resource "aws_service_discovery_service" "this" {
  count = var.service_discovery_namespace_id == null ? 0 : 1

  name = var.service_discovery_name

  dns_config {
    namespace_id = var.service_discovery_namespace_id

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  tags = var.tags
}

resource "aws_ecs_service" "this" {
  name            = "${var.name}-qdrant"
  cluster         = var.cluster_arn
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  deployment_minimum_healthy_percent = 0
  deployment_maximum_percent         = 100
  enable_execute_command             = false

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [aws_security_group.qdrant.id]
    assign_public_ip = false
  }

  dynamic "service_registries" {
    for_each = aws_service_discovery_service.this

    content {
      registry_arn = service_registries.value.arn
    }
  }

  depends_on = [aws_efs_mount_target.this]

  tags = var.tags
}
