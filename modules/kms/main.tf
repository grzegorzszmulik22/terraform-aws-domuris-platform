locals {
  tags = merge(var.tags, {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "terraform"
  })
}

resource "aws_kms_key" "this" {
  description             = "${var.project} ${var.environment} application key"
  deletion_window_in_days = var.deletion_window_in_days
  enable_key_rotation     = true

  tags = local.tags
}

resource "aws_kms_alias" "this" {
  name          = "alias/${var.alias_name}"
  target_key_id = aws_kms_key.this.key_id
}
