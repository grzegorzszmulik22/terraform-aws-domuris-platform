# redis-cache

Private ElastiCache Redis 7 replication group (single shard, optional replicas).

## What it creates

- Subnet group in the private subnets
- Security group allowing 6379 only from the listed security groups
- Parameter group with `maxmemory-policy = allkeys-lru`
- Replication group; automatic failover and Multi-AZ turn on when `replicas_per_node_group > 0`

## Security defaults

- Encryption at rest with the supplied KMS key
- Encryption in transit (TLS) and an AUTH token
- Daily snapshots kept for 7 days
- Changes are applied in the maintenance window (`apply_immediately = false`)

## Usage

See [`examples/`](../../examples) for a full composition.

```hcl
module "redis_cache" {
  source = "git::https://github.com/grzegorzszmulik22/terraform-aws-domuris-platform.git//modules/redis-cache?ref=v0.1.1"
  # required inputs listed below
}
```

<!-- BEGIN_TF_DOCS -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `allowed_security_group_ids` | Security groups allowed to connect to Redis. | `list(string)` | n/a | yes |
| `auth_token` | Redis AUTH token. Sensitive. | `string` | n/a | yes |
| `kms_key_id` | KMS key ARN or ID for at-rest encryption. | `string` | n/a | yes |
| `name` | Cache name prefix. | `string` | n/a | yes |
| `private_subnet_ids` | Private subnet IDs for Redis. | `list(string)` | n/a | yes |
| `vpc_id` | VPC ID. | `string` | n/a | yes |
| `engine_version` | Redis engine version. | `string` | `"7.1"` | no |
| `node_type` | ElastiCache node type. | `string` | `"cache.t4g.micro"` | no |
| `replicas_per_node_group` | Replica count for the single Redis shard. | `number` | `0` | no |
| `tags` | Tags applied to resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `cluster_id` | ElastiCache replication group ID. |
| `endpoint` | Redis primary endpoint address. |
| `port` | Redis port. |
| `reader_endpoint` | Redis reader endpoint address. |
| `security_group_id` | Redis security group ID. |
<!-- END_TF_DOCS -->
