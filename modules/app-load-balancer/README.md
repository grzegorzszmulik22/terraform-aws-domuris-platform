# app-load-balancer

Internet-facing Application Load Balancer for the API, with an optional regional WAF.

## What it creates

- Security group allowing 80 and 443 from anywhere
- ALB and an IP target group for the API (port 8000, health check on `health_check_path`)
- With `certificate_arn`: HTTPS listener plus an HTTP listener that redirects to HTTPS (301)
- Without `certificate_arn`: a plain HTTP listener only (intended for bootstrapping, not production)
- Optional WAFv2 web ACL: per-IP rate limit, AWS Common Rule Set, Known Bad Inputs

## Security defaults

- TLS policy `ELBSecurityPolicy-TLS13-1-2-2021-06` (TLS 1.2 and 1.3 only)
- Deletion protection is always enabled on the ALB
- WAF is enabled by default (`enable_waf = true`)

## Notes

The target group port is fixed at 8000, matching the default `container_port` of `ecs-api-service`.

## Usage

See [`examples/`](../../examples) for a full composition.

```hcl
module "app_load_balancer" {
  source = "git::https://github.com/grzegorzszmulik22/terraform-aws-domuris-platform.git//modules/app-load-balancer?ref=v0.2.0"
  # required inputs listed below
}
```

<!-- BEGIN_TF_DOCS -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `name` | Load balancer name prefix. | `string` | n/a | yes |
| `public_subnet_ids` | Public subnet IDs for the ALB. | `list(string)` | n/a | yes |
| `vpc_id` | VPC ID. | `string` | n/a | yes |
| `certificate_arn` | ACM certificate ARN. When null, the module creates HTTP only. | `string` | `null` | no |
| `enable_waf` | Create and attach a regional WAF web ACL. | `bool` | `true` | no |
| `health_check_path` | Application health check path. | `string` | `"/health"` | no |
| `tags` | Tags applied to resources. | `map(string)` | `{}` | no |
| `waf_rate_limit` | Maximum requests per five-minute window per source IP. | `number` | `2000` | no |

## Outputs

| Name | Description |
|------|-------------|
| `alb_arn` | ALB ARN. |
| `alb_arn_suffix` | ALB ARN suffix used by CloudWatch metrics. |
| `alb_dns_name` | ALB DNS name. |
| `alb_zone_id` | ALB zone ID. |
| `api_target_group_arn` | API target group ARN. |
| `api_target_group_arn_suffix` | API target group ARN suffix used by CloudWatch metrics. |
| `security_group_id` | ALB security group ID. |
| `waf_web_acl_arn` | WAF web ACL ARN when enabled. |
<!-- END_TF_DOCS -->
