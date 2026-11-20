# cloudwatch-alarms

Baseline CloudWatch alarms for ECS, ALB, RDS and Redis, routed to an SNS topic.

## What it creates

- SNS topic with optional email subscriptions
- Per ECS service: CPU above 80% and memory above 85% for 3 minutes
- ALB target 5xx count above 10 per 5 minutes (when ALB and target group suffixes are set)
- RDS CPU above 80% and free storage below 10 GiB (when `rds_instance_id` is set)
- Redis engine CPU above 75% (when `redis_replication_group_id` is set)

## Security defaults

- Alarms send both ALARM and OK notifications
- The RDS free-storage alarm treats missing data as breaching

## Usage

See [`examples/`](../../examples) for a full composition.

```hcl
module "cloudwatch_alarms" {
  source = "git::https://github.com/grzegorzszmulik22/terraform-aws-domuris-platform.git//modules/cloudwatch-alarms?ref=v0.2.0"
  # required inputs listed below
}
```

<!-- BEGIN_TF_DOCS -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `ecs_cluster_name` | ECS cluster name. | `string` | n/a | yes |
| `name` | Alarm name prefix. | `string` | n/a | yes |
| `alb_arn_suffix` | ALB ARN suffix for ApplicationELB metrics. | `string` | `null` | no |
| `ecs_service_names` | ECS services monitored for CPU and memory. | `list(string)` | `[]` | no |
| `notification_email_endpoints` | Email endpoints subscribed to the alarm SNS topic. | `list(string)` | `[]` | no |
| `rds_instance_id` | RDS instance identifier. | `string` | `null` | no |
| `redis_replication_group_id` | ElastiCache replication group identifier. | `string` | `null` | no |
| `tags` | Tags applied to supported resources. | `map(string)` | `{}` | no |
| `target_group_arn_suffix` | Target group ARN suffix for ApplicationELB metrics. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| `alarm_names` | Created CloudWatch alarm names. |
| `topic_arn` | SNS topic ARN for alarms. |
<!-- END_TF_DOCS -->
