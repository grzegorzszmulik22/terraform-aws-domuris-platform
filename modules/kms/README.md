# kms

Customer managed KMS key and alias shared by the platform's encrypted resources.

## What it creates

- Symmetric KMS key
- Alias `alias/<alias_name>`

## Security defaults

- Automatic key rotation enabled
- Deletion window of 30 days by default

## Usage

See [`examples/`](../../examples) for a full composition.

```hcl
module "kms" {
  source = "git::https://github.com/grzegorzszmulik22/terraform-aws-domuris-platform.git//modules/kms?ref=v0.1.1"
  # required inputs listed below
}
```

<!-- BEGIN_TF_DOCS -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `alias_name` | KMS alias without the alias/ prefix. | `string` | n/a | yes |
| `environment` | Deployment environment. | `string` | n/a | yes |
| `project` | Project name. | `string` | n/a | yes |
| `deletion_window_in_days` | KMS key deletion window. | `number` | `30` | no |
| `tags` | Tags applied to resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `alias_name` | KMS alias name. |
| `key_arn` | KMS key ARN. |
| `key_id` | KMS key ID. |
<!-- END_TF_DOCS -->
