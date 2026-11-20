# backup-bucket

Private, versioned, KMS-encrypted S3 bucket for database dumps and exports.

## What it creates

- S3 bucket with all four public access blocks enabled
- Versioning
- Default SSE-KMS encryption with the supplied key
- Lifecycle rule: current objects expire after `retention_days`, noncurrent versions after 30 days

## Security defaults

- Public access fully blocked
- SSE-KMS with a customer managed key (required input)
- Versioning enabled

## Usage

See [`examples/`](../../examples) for a full composition.

```hcl
module "backup_bucket" {
  source = "git::https://github.com/grzegorzszmulik22/terraform-aws-domuris-platform.git//modules/backup-bucket?ref=v0.2.0"
  # required inputs listed below
}
```

<!-- BEGIN_TF_DOCS -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `bucket_name` | Globally unique S3 bucket name. | `string` | n/a | yes |
| `kms_key_arn` | KMS key ARN for bucket encryption. | `string` | n/a | yes |
| `retention_days` | Days before backup objects expire. | `number` | `90` | no |
| `tags` | Tags applied to resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `bucket_arn` | Backup bucket ARN. |
| `bucket_name` | Backup bucket name. |
<!-- END_TF_DOCS -->
