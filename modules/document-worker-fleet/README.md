# document-worker-fleet

Small, private EC2 fleet for host-based work that does not fit ECS Fargate (migrations, document ingestion, vendor tooling).

## What it creates

- Egress-only security group
- IAM role and instance profile with SSM Session Manager and CloudWatch agent policies
- Optional inline policy scoped to the listed secrets, S3 buckets and KMS keys
- `instance_count` EC2 instances spread across the private subnets, AMI looked up by name pattern (Amazon Linux 2023 by default) unless `ami_id` is set
- Optional encrypted EBS data volume per instance

## Security defaults

- IMDSv2 required (`http_tokens = required`, hop limit 1)
- Root and data volumes encrypted by default, optionally with a customer managed key
- No inbound rules; access is through SSM rather than SSH (`key_name` is optional)
- IAM access limited to explicitly passed ARNs
- `ignore_changes` on AMI, user data, subnet and security groups so routine plans do not replace hosts

## Usage

See [`examples/`](../../examples) for a full composition.

```hcl
module "document_worker_fleet" {
  source = "git::https://github.com/grzegorzszmulik22/terraform-aws-domuris-platform.git//modules/document-worker-fleet?ref=v0.1.1"
  # required inputs listed below
}
```

<!-- BEGIN_TF_DOCS -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `name_prefix` | Prefix used for worker instance names and IAM resources. | `string` | n/a | yes |
| `private_subnet_ids` | Private subnets used to spread worker instances. | `list(string)` | n/a | yes |
| `vpc_id` | VPC ID where the worker security group is created. | `string` | n/a | yes |
| `additional_security_group_ids` | Additional security groups attached to each worker. | `list(string)` | `[]` | no |
| `ami_id` | Explicit AMI ID. When null, the module searches by ami_name_pattern. | `string` | `null` | no |
| `ami_name_pattern` | AMI name pattern used when ami_id is not supplied. | `string` | `"al2023-ami-*-x86_64"` | no |
| `ami_owners` | AMI owners used when ami_id is not supplied. | `list(string)` | `["amazon"]` | no |
| `artifact_bucket_arns` | S3 bucket ARNs used for document artifacts or batch inputs. | `list(string)` | `[]` | no |
| `data_volume` | Optional attached EBS data volume used for OCR or ingestion scratch space. | `object({ device_name = string volume_type = string volume_size = number encrypted = bool kms_key_id = optional(string) })` | `null` | no |
| `ebs_optimized` | Whether EBS optimization is enabled for supported instance types. | `bool` | `true` | no |
| `instance_count` | Number of worker instances. | `number` | `1` | no |
| `instance_type` | EC2 instance type for document workers. | `string` | `"t3.small"` | no |
| `key_name` | Optional EC2 key pair name. Prefer SSM Session Manager for access. | `string` | `null` | no |
| `kms_key_arns` | KMS key ARNs used to decrypt secrets, S3 objects, or EBS volumes. | `list(string)` | `[]` | no |
| `root_block_device` | Root volume configuration. | `object({ volume_type = string volume_size = number encrypted = bool kms_key_id = optional(string) delete_on_termination = optional(bool, true) })` | `{ volume_type = "gp3" volume_size = 40 encrypted = true }` | no |
| `secrets_arns` | Secrets Manager ARNs the worker can read. | `list(string)` | `[]` | no |
| `tags` | Base tags applied to resources. | `map(string)` | `{}` | no |
| `user_data_template_path` | Optional local template path for bootstrap user data. | `string` | `null` | no |
| `user_data_vars` | Additional variables passed into the user data template. | `map(string)` | `{}` | no |
| `worker_tags` | Additional tags applied only to worker instances and volumes. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `data_volume_ids` | Attached data volume IDs. |
| `instance_ids` | Worker instance IDs. |
| `instance_names` | Worker instance names. |
| `instance_profile_name` | IAM instance profile name. |
| `private_ips` | Worker private IP addresses. |
| `security_group_id` | Worker security group ID. |
<!-- END_TF_DOCS -->
