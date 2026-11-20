# email-dns

SES domain identity with the DNS records needed for authenticated sending, in Route53.

## What it creates

- SES domain identity and verification TXT record
- Easy DKIM with the three DKIM CNAME records
- Custom MAIL FROM domain with MX and SPF records
- DMARC record (`p=quarantine` by default, optional aggregate report address)

## Security defaults

- SPF ends in `-all`
- DMARC defaults to `quarantine`

## Usage

See [`examples/`](../../examples) for a full composition.

```hcl
module "email_dns" {
  source = "git::https://github.com/grzegorzszmulik22/terraform-aws-domuris-platform.git//modules/email-dns?ref=v0.2.0"
  # required inputs listed below
}
```

<!-- BEGIN_TF_DOCS -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `domain_name` | Domain verified for application email. | `string` | n/a | yes |
| `zone_id` | Route53 hosted zone ID for domain_name. | `string` | n/a | yes |
| `dmarc_policy` | DMARC policy. | `string` | `"quarantine"` | no |
| `dmarc_reports_email` | Optional aggregate report email address. | `string` | `null` | no |
| `mail_from_subdomain` | MAIL FROM subdomain. | `string` | `"mail"` | no |
| `tags` | Tags applied to supported resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `dkim_record_names` | DKIM Route53 record names. |
| `domain_identity_arn` | SES domain identity ARN. |
| `mail_from_domain` | Configured MAIL FROM domain. |
<!-- END_TF_DOCS -->
