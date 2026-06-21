data "aws_ami" "selected" {
  count = var.ami_id == null ? 1 : 0

  most_recent = true
  owners      = var.ami_owners

  filter {
    name   = "name"
    values = [var.ami_name_pattern]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

data "aws_iam_policy_document" "assume_ec2" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "worker_access" {
  dynamic "statement" {
    for_each = length(var.secrets_arns) == 0 ? [] : [1]

    content {
      sid       = "ReadConfiguredSecrets"
      actions   = ["secretsmanager:GetSecretValue"]
      resources = var.secrets_arns
    }
  }

  dynamic "statement" {
    for_each = length(var.artifact_bucket_arns) == 0 ? [] : [1]

    content {
      sid       = "ReadWriteDocumentArtifacts"
      actions   = ["s3:GetObject", "s3:PutObject", "s3:AbortMultipartUpload"]
      resources = local.artifact_object_arns
    }
  }

  dynamic "statement" {
    for_each = length(var.kms_key_arns) == 0 ? [] : [1]

    content {
      sid       = "UseConfiguredKmsKeys"
      actions   = ["kms:Decrypt", "kms:GenerateDataKey"]
      resources = var.kms_key_arns
    }
  }
}
