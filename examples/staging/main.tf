module "network" {
  source = "../../modules/network"

  project              = var.project
  environment          = var.environment
  vpc_cidr             = "10.42.0.0/16"
  public_subnet_cidrs  = ["10.42.0.0/24", "10.42.1.0/24"]
  private_subnet_cidrs = ["10.42.10.0/24", "10.42.11.0/24"]
  enable_nat_gateway   = true
  tags                 = local.tags
}

module "kms" {
  source = "../../modules/kms"

  project     = var.project
  environment = var.environment
  alias_name  = local.name
  tags        = local.tags
}

module "secrets" {
  source = "../../modules/secrets"

  project     = var.project
  environment = var.environment
  kms_key_id  = module.kms.key_id
  secret_names = [
    "APP_SECRET_KEY",
    "OPENAI_API_KEY",
    "REDIS_AUTH_TOKEN",
    "SENTRY_DSN"
  ]
  tags = local.tags
}

module "backups" {
  source = "../../modules/backup-bucket"

  bucket_name = "${local.name}-backups"
  kms_key_arn = module.kms.key_arn
  tags        = local.tags
}

resource "aws_security_group" "app_identity" {
  name        = "${local.name}-app-identity"
  description = "Stable identity attached to application workloads"
  vpc_id      = module.network.vpc_id

  tags = merge(local.tags, {
    Name = "${local.name}-app-identity"
  })
}

resource "aws_ecs_cluster" "this" {
  name = local.name

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = local.tags
}

resource "aws_service_discovery_private_dns_namespace" "this" {
  name        = "${local.name}.internal"
  description = "Private service discovery for Domuris services"
  vpc         = module.network.vpc_id
  tags        = local.tags
}

module "alb" {
  source = "../../modules/app-load-balancer"

  name              = local.name
  vpc_id            = module.network.vpc_id
  public_subnet_ids = module.network.public_subnet_ids
  certificate_arn   = var.certificate_arn
  enable_waf        = true
  waf_rate_limit    = 2000
  tags              = local.tags
}

resource "aws_route53_record" "app" {
  count = var.route53_zone_id == null ? 0 : 1

  zone_id = var.route53_zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = module.alb.alb_dns_name
    zone_id                = module.alb.alb_zone_id
    evaluate_target_health = true
  }
}

module "rds" {
  source = "../../modules/rds-postgres"

  name                       = local.name
  vpc_id                     = module.network.vpc_id
  private_subnet_ids         = module.network.private_subnet_ids
  allowed_security_group_ids = [aws_security_group.app_identity.id]
  kms_key_id                 = module.kms.key_id
  backup_retention_period    = 14
  deletion_protection        = true
  tags                       = local.tags
}

module "redis" {
  source = "../../modules/redis-cache"

  name                       = local.name
  vpc_id                     = module.network.vpc_id
  private_subnet_ids         = module.network.private_subnet_ids
  allowed_security_group_ids = [aws_security_group.app_identity.id]
  kms_key_id                 = module.kms.key_id
  auth_token                 = var.redis_auth_token
  tags                       = local.tags
}

module "qdrant" {
  source = "../../modules/qdrant-service"

  name                           = local.name
  cluster_arn                    = aws_ecs_cluster.this.arn
  vpc_id                         = module.network.vpc_id
  private_subnet_ids             = module.network.private_subnet_ids
  allowed_security_group_ids     = [aws_security_group.app_identity.id]
  kms_key_id                     = module.kms.key_id
  service_discovery_namespace_id = aws_service_discovery_private_dns_namespace.this.id
  tags                           = local.tags
}

module "api" {
  source = "../../modules/ecs-api-service"

  name                          = "${local.name}-api"
  cluster_arn                   = aws_ecs_cluster.this.arn
  vpc_id                        = module.network.vpc_id
  private_subnet_ids            = module.network.private_subnet_ids
  alb_security_group_id         = module.alb.security_group_id
  target_group_arn              = module.alb.api_target_group_arn
  container_image               = var.api_image
  additional_security_group_ids = [aws_security_group.app_identity.id]
  desired_count                 = 2
  task_policy_json              = data.aws_iam_policy_document.app_task.json
  secret_kms_key_arns           = [module.kms.key_arn]

  environment = {
    ENVIRONMENT   = var.environment
    DATABASE_HOST = module.rds.endpoint
    DATABASE_PORT = tostring(module.rds.port)
    REDIS_HOST    = module.redis.endpoint
    QDRANT_URL    = "http://${module.qdrant.service_discovery_name}.${aws_service_discovery_private_dns_namespace.this.name}:6333"
  }

  secret_arns = merge(module.secrets.secret_arns, {
    DB_MASTER_SECRET = module.rds.master_user_secret_arn
  })

  tags = local.tags
}

module "worker" {
  source = "../../modules/ecs-worker-service"

  name                          = "${local.name}-worker"
  cluster_arn                   = aws_ecs_cluster.this.arn
  vpc_id                        = module.network.vpc_id
  private_subnet_ids            = module.network.private_subnet_ids
  container_image               = var.worker_image
  command                       = ["python", "-m", "app.jobs.worker"]
  additional_security_group_ids = [aws_security_group.app_identity.id]
  desired_count                 = 1
  task_policy_json              = data.aws_iam_policy_document.app_task.json
  secret_kms_key_arns           = [module.kms.key_arn]

  environment = {
    ENVIRONMENT   = var.environment
    DATABASE_HOST = module.rds.endpoint
    REDIS_HOST    = module.redis.endpoint
    QDRANT_URL    = "http://${module.qdrant.service_discovery_name}.${aws_service_discovery_private_dns_namespace.this.name}:6333"
  }

  secret_arns = merge(module.secrets.secret_arns, {
    DB_MASTER_SECRET = module.rds.master_user_secret_arn
  })

  tags = local.tags
}

module "document_worker_fleet" {
  source = "../../modules/document-worker-fleet"

  name_prefix                   = "${local.name}-doc"
  vpc_id                        = module.network.vpc_id
  private_subnet_ids            = module.network.private_subnet_ids
  instance_count                = 1
  instance_type                 = "t3.small"
  additional_security_group_ids = [aws_security_group.app_identity.id]
  user_data_template_path       = "${path.module}/templates/worker-user-data.sh.tftpl"
  user_data_vars = {
    environment     = var.environment
    artifact_bucket = module.backups.bucket_name
  }
  secrets_arns         = values(module.secrets.secret_arns)
  artifact_bucket_arns = [module.backups.bucket_arn]
  kms_key_arns         = [module.kms.key_arn]

  data_volume = {
    device_name = "/dev/sdf"
    volume_type = "gp3"
    volume_size = 80
    encrypted   = true
    kms_key_id  = module.kms.key_id
  }

  tags = local.tags
  worker_tags = {
    Workload = "document-ingestion"
  }
}

module "alarms" {
  source = "../../modules/cloudwatch-alarms"

  name                         = local.name
  ecs_cluster_name             = aws_ecs_cluster.this.name
  ecs_service_names            = [module.api.service_name, module.worker.service_name, module.qdrant.service_name]
  alb_arn_suffix               = module.alb.alb_arn_suffix
  target_group_arn_suffix      = module.alb.api_target_group_arn_suffix
  rds_instance_id              = module.rds.instance_id
  redis_replication_group_id   = module.redis.cluster_id
  notification_email_endpoints = var.notification_email_endpoints
  tags                         = local.tags
}
