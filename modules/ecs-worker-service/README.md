# ecs-worker-service

ECS Fargate service for background workers (no load balancer).

## What it creates

- CloudWatch log group `/ecs/<name>` with 30-day retention
- Task execution role and task role, with an optional inline task policy
- Egress-only security group
- Fargate task definition with optional command override, and service

## Security defaults

- Tasks run in private subnets without public IPs
- No inbound rules
- ECS Exec disabled
- Secrets are injected from Secrets Manager by ARN

## Usage

See [`examples/`](../../examples) for a full composition.

```hcl
module "ecs_worker_service" {
  source = "git::https://github.com/grzegorzszmulik22/terraform-aws-domuris-platform.git//modules/ecs-worker-service?ref=v0.1.1"
  # required inputs listed below
}
```

<!-- BEGIN_TF_DOCS -->
## Security defaults note

The task execution role gets `secretsmanager:GetSecretValue` on exactly the ARNs in `secret_arns` (and `kms:Decrypt` on `secret_kms_key_arns`), because ECS injects container secrets with the execution role.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `cluster_arn` | ECS cluster ARN. | `string` | n/a | yes |
| `container_image` | Container image for the worker. | `string` | n/a | yes |
| `name` | Name used for the ECS service, task family, IAM roles, and log group. | `string` | n/a | yes |
| `private_subnet_ids` | Private subnet IDs for Fargate tasks. | `list(string)` | n/a | yes |
| `vpc_id` | VPC ID for the service security group. | `string` | n/a | yes |
| `additional_security_group_ids` | Additional security groups attached to tasks. | `list(string)` | `[]` | no |
| `command` | Optional container command override. | `list(string)` | `[]` | no |
| `cpu` | Fargate task CPU units. | `number` | `512` | no |
| `desired_count` | Number of running tasks. | `number` | `1` | no |
| `environment` | Plain environment variables passed to the container. | `map(string)` | `{}` | no |
| `memory` | Fargate task memory in MiB. | `number` | `1024` | no |
| `secret_arns` | Secrets Manager ARNs injected as container secrets, keyed by environment variable name. | `map(string)` | `{}` | no |
| `secret_kms_key_arns` | Customer-managed KMS key ARNs that encrypt the secrets in secret_arns; the execution role may decrypt with them. Leave empty for the AWS-managed key. | `list(string)` | `[]` | no |
| `tags` | Tags applied to resources. | `map(string)` | `{}` | no |
| `task_policy_json` | Optional IAM policy JSON attached inline to the task role. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| `log_group_name` | CloudWatch log group name. |
| `security_group_id` | Worker service security group ID. |
| `service_name` | ECS service name. |
| `task_role_arn` | Task role ARN. |
<!-- END_TF_DOCS -->
