data "aws_iam_policy_document" "app_task" {
  statement {
    sid     = "ReadRuntimeSecrets"
    actions = ["secretsmanager:GetSecretValue"]
    resources = concat(
      values(module.secrets.secret_arns),
      [module.rds.master_user_secret_arn]
    )
  }

  statement {
    sid       = "UseRuntimeKmsKey"
    actions   = ["kms:Decrypt", "kms:GenerateDataKey"]
    resources = [module.kms.key_arn]
  }

  statement {
    sid       = "WriteBackupsAndExports"
    actions   = ["s3:GetObject", "s3:PutObject", "s3:AbortMultipartUpload"]
    resources = ["${module.backups.bucket_arn}/*"]
  }
}
