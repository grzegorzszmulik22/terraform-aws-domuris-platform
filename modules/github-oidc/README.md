# github-oidc

GitHub Actions OIDC provider and an IAM role that workflows can assume without static AWS keys.

## What it creates

- IAM OIDC identity provider for `token.actions.githubusercontent.com`
- IAM role trusted only by that provider
- Optional inline policy from `policy_json`

## Security defaults

- Trust requires audience `sts.amazonaws.com`
- Trust is limited to `repo:<github_owner>/<repo>:*` for the listed repositories
- No permissions are attached unless `policy_json` is provided

## Usage

See [`examples/`](../../examples) for a full composition.

```hcl
module "github_oidc" {
  source = "git::https://github.com/grzegorzszmulik22/terraform-aws-domuris-platform.git//modules/github-oidc?ref=v0.2.0"
  # required inputs listed below
}
```

<!-- BEGIN_TF_DOCS -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `github_owner` | GitHub organization or user. | `string` | n/a | yes |
| `repositories` | Repository names allowed to assume the role. | `list(string)` | n/a | yes |
| `role_name` | IAM role name for GitHub Actions. | `string` | n/a | yes |
| `policy_json` | Least-privilege IAM policy JSON attached to the role. | `string` | `null` | no |
| `tags` | Tags applied to supported resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `provider_arn` | GitHub OIDC provider ARN. |
| `role_arn` | GitHub Actions role ARN. |
<!-- END_TF_DOCS -->
