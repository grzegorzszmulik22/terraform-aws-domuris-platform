# qdrant-service

Internal Qdrant vector database on ECS Fargate with persistent, encrypted EFS storage.

## What it creates

- CloudWatch log group with 30-day retention
- Security group allowing 6333 (HTTP) and 6334 (gRPC) only from the listed security groups
- EFS file system, mount targets and an access point (`/qdrant`, uid/gid 1000, mode 0750)
- Fargate task definition and service, optionally registered in Cloud Map

## Security defaults

- EFS encrypted at rest with the supplied KMS key and in transit (`transit_encryption = ENABLED`)
- NFS reachable only from the Qdrant security group
- Tasks run in private subnets without public IPs; ECS Exec disabled
- Deployment settings (0% / 100%) avoid two tasks writing to the same volume

## Notes

Qdrant is not configured with an API key here; access control relies on the security group.

## Usage

See [`examples/`](../../examples) for a full composition.

```hcl
module "qdrant_service" {
  source = "git::https://github.com/grzegorzszmulik22/terraform-aws-domuris-platform.git//modules/qdrant-service?ref=v0.1.1"
  # required inputs listed below
}
```

<!-- BEGIN_TF_DOCS -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `allowed_security_group_ids` | Security groups allowed to reach Qdrant on ports 6333 (HTTP) and 6334 (gRPC). | `list(string)` | n/a | yes |
| `cluster_arn` | ECS cluster ARN. | `string` | n/a | yes |
| `kms_key_id` | KMS key ARN or ID for EFS encryption. | `string` | n/a | yes |
| `name` | Name prefix for the Qdrant service, task family, IAM roles, and EFS resources. | `string` | n/a | yes |
| `private_subnet_ids` | Private subnet IDs for Fargate tasks and EFS mount targets. | `list(string)` | n/a | yes |
| `vpc_id` | VPC ID for the Qdrant and EFS security groups. | `string` | n/a | yes |
| `container_image` | Qdrant container image. | `string` | `"qdrant/qdrant:v1.12.4"` | no |
| `cpu` | Fargate task CPU units. | `number` | `1024` | no |
| `desired_count` | Number of running tasks. Qdrant uses a single EFS-backed volume, so keep this at 1. | `number` | `1` | no |
| `memory` | Fargate task memory in MiB. | `number` | `2048` | no |
| `service_discovery_name` | Cloud Map service name used when service_discovery_namespace_id is set. | `string` | `"qdrant"` | no |
| `service_discovery_namespace_id` | Optional Cloud Map private DNS namespace ID. | `string` | `null` | no |
| `tags` | Tags applied to resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `efs_file_system_id` | Qdrant EFS file system ID. |
| `log_group_name` | CloudWatch log group name. |
| `security_group_id` | Qdrant service security group ID. |
| `service_discovery_name` | Cloud Map service name, when enabled. |
| `service_name` | ECS service name. |
<!-- END_TF_DOCS -->
