# rds-postgres

Private PostgreSQL 16 instance on RDS.

## What it creates

- DB subnet group in the private subnets
- Security group allowing 5432 only from the listed security groups
- Parameter group: `rds.force_ssl = 1`, slow query logging above 1 second
- RDS instance on gp3 storage with storage autoscaling

## Security defaults

- Storage encrypted with the supplied KMS key
- SSL required for client connections
- Master password generated and stored by RDS in Secrets Manager (`manage_master_user_password`)
- Not publicly accessible
- Deletion protection on and a final snapshot taken by default
- Automated backups (7 days by default), PostgreSQL and upgrade logs exported to CloudWatch, Performance Insights enabled

## Usage

See [`examples/`](../../examples) for a full composition.

```hcl
module "rds_postgres" {
  source = "git::https://github.com/grzegorzszmulik22/terraform-aws-domuris-platform.git//modules/rds-postgres?ref=v0.2.0"
  # required inputs listed below
}
```

<!-- BEGIN_TF_DOCS -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `allowed_security_group_ids` | Security groups allowed to connect to PostgreSQL. | `list(string)` | n/a | yes |
| `kms_key_id` | KMS key ARN or ID for storage encryption. | `string` | n/a | yes |
| `name` | Database identifier prefix. | `string` | n/a | yes |
| `private_subnet_ids` | Private subnet IDs for the DB subnet group. | `list(string)` | n/a | yes |
| `vpc_id` | VPC ID. | `string` | n/a | yes |
| `allocated_storage` | Initial storage in GiB. | `number` | `40` | no |
| `backup_retention_period` | Backup retention period in days. | `number` | `7` | no |
| `database_name` | Initial database name. | `string` | `"domuris"` | no |
| `deletion_protection` | Protect the instance from accidental deletion. | `bool` | `true` | no |
| `engine_version` | PostgreSQL engine version. | `string` | `"16.3"` | no |
| `instance_class` | RDS instance class. | `string` | `"db.t4g.micro"` | no |
| `master_username` | Master username. | `string` | `"domuris_admin"` | no |
| `max_allocated_storage` | Maximum autoscaled storage in GiB. | `number` | `120` | no |
| `multi_az` | Whether the DB runs in Multi-AZ mode. | `bool` | `false` | no |
| `skip_final_snapshot` | Skip final snapshot on destroy. Keep false for persistent environments. | `bool` | `false` | no |
| `tags` | Tags applied to resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `endpoint` | RDS endpoint. |
| `instance_id` | RDS instance identifier. |
| `master_user_secret_arn` | Secrets Manager ARN for the managed master password. |
| `port` | RDS port. |
| `security_group_id` | RDS security group ID. |
<!-- END_TF_DOCS -->
