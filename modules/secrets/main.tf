resource "aws_secretsmanager_secret" "this" {
  for_each = var.secret_names

  name                    = "${local.name_prefix}/${each.value}"
  description             = "Managed application secret for ${each.value}"
  kms_key_id              = var.kms_key_id
  recovery_window_in_days = 7

  tags = local.tags
}
