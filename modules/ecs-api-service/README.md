# ecs-api-service

ECS Fargate service for the HTTP API, registered with an ALB target group.

## What it creates

- CloudWatch log group `/ecs/<name>` with 30-day retention
- Task execution role and task role, with an optional inline task policy
- Security group allowing the container port only from the ALB security group
- Fargate task definition (environment variables and Secrets Manager secrets) and service

## Security defaults

- Tasks run in private subnets without public IPs
- Ingress only from the ALB security group
- ECS Exec disabled
- Secrets are injected from Secrets Manager by ARN, not passed as plain environment variables
- Rolling deployment keeps 100% healthy capacity

## Usage

See [`examples/`](../../examples) for a full composition.

```hcl
module "ecs_api_service" {
  source = "git::https://github.com/grzegorzszmulik22/terraform-aws-domuris-platform.git//modules/ecs-api-service?ref=v0.2.0"
  # required inputs listed below
}
```

<!-- BEGIN_TF_DOCS -->
## Security defaults note

The task execution role gets `secretsmanager:GetSecretValue` on exactly the ARNs in `secret_arns` (and `kms:Decrypt` on `secret_kms_key_arns`), because ECS injects container secrets with the execution role.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `alb_security_group_id` | ALB security group allowed to reach the container port. | `string` | n/a | yes |
| `cluster_arn` | ECS cluster ARN. | `string` | n/a | yes |
| `container_image` | Container image for the API. | `string` | n/a | yes |
| `name` | Name used for the ECS service, task family, IAM roles, and log group. | `string` | n/a | yes |
| `private_subnet_ids` | Private subnet IDs for Fargate tasks. | `list(string)` | n/a | yes |
| `target_group_arn` | ALB target group ARN the service registers with. | `string` | n/a | yes |
| `vpc_id` | VPC ID for the service security group. | `string` | n/a | yes |
| `additional_security_group_ids` | Additional security groups attached to tasks. | `list(string)` | `[]` | no |
| `container_port` | Container port exposed to the ALB. | `number` | `8000` | no |
| `cpu` | Fargate task CPU units. | `number` | `512` | no |
| `desired_count` | Number of running tasks. | `number` | `2` | no |
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
| `service_name` | ECS service name. |
| `service_security_group_id` | API service security group ID. |
| `task_role_arn` | Task role ARN. |
<!-- END_TF_DOCS -->
