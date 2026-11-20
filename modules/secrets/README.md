# secrets

Secrets Manager secret containers for application configuration; values are set outside Terraform.

## What it creates

- One secret per name, at `<project>/<environment>/<name>`

## Security defaults

- Encrypted with the supplied KMS key
- Secret values are not managed by Terraform, so they never enter state
- 7-day recovery window on deletion

## Notes

Set values with the AWS CLI or console after apply, for example `aws secretsmanager put-secret-value --secret-id <project>/<environment>/<name> --secret-string ...`.

## Usage

See [`examples/`](../../examples) for a full composition.

```hcl
module "secrets" {
  source = "git::https://github.com/grzegorzszmulik22/terraform-aws-domuris-platform.git//modules/secrets?ref=v0.1.1"
  # required inputs listed below
}
```

<!-- BEGIN_TF_DOCS -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `environment` | Deployment environment. | `string` | n/a | yes |
| `kms_key_id` | KMS key used for Secrets Manager encryption. | `string` | n/a | yes |
| `project` | Project name. | `string` | n/a | yes |
| `secret_names` | Logical secret names to create. Values are not managed here. | `set(string)` | n/a | yes |
| `tags` | Tags applied to resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `secret_arns` | Secret ARNs keyed by logical secret name. |
| `secret_names` | Secret names keyed by logical secret name. |
<!-- END_TF_DOCS -->
