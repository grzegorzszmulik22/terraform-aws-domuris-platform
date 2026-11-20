# terraform-aws-domuris-platform

Terraform modules for the AWS platform layer of a multi-service SaaS application: network, compute, data stores, secrets, edge security, email DNS, alarms and CI/CD access.

They were built for Domuris, a property-management SaaS platform, and are kept generic: names, domains and sizes are inputs. Observability modules live in [terraform-aws-domuris-observability](https://github.com/grzegorzszmulik22/terraform-aws-domuris-observability).

## Modules

| Module | Creates | Key security defaults |
|--------|---------|-----------------------|
| [network](modules/network) | VPC, public and private subnets, internet gateway, optional NAT gateway | No public IPs on launch; private subnets have no internet gateway route |
| [app-load-balancer](modules/app-load-balancer) | Public ALB, API target group, HTTP to HTTPS redirect, optional WAFv2 | TLS 1.2/1.3 policy, deletion protection, WAF on by default (rate limit and AWS managed rules) |
| [ecs-api-service](modules/ecs-api-service) | ECS Fargate API service, IAM roles, log group | Private subnets, no public IP, ingress only from the ALB, ECS Exec off, secrets from Secrets Manager |
| [ecs-worker-service](modules/ecs-worker-service) | ECS Fargate background worker service | Private subnets, no inbound rules, ECS Exec off |
| [document-worker-fleet](modules/document-worker-fleet) | Private EC2 instances for host-based jobs, IAM instance profile, optional data volumes | IMDSv2 required, encrypted volumes, SSM access instead of SSH, IAM scoped to passed ARNs |
| [rds-postgres](modules/rds-postgres) | RDS PostgreSQL 16, subnet group, parameter group, security group | KMS-encrypted storage, `rds.force_ssl`, RDS-managed master password, deletion protection, final snapshot, not public |
| [redis-cache](modules/redis-cache) | ElastiCache Redis 7 replication group | Encryption at rest (KMS) and in transit, AUTH token, private ingress only |
| [qdrant-service](modules/qdrant-service) | Qdrant vector database on ECS Fargate with EFS storage and Cloud Map | EFS encrypted at rest (KMS) and in transit, ingress only from listed security groups |
| [secrets](modules/secrets) | Secrets Manager secrets (names only) | KMS-encrypted; values are set outside Terraform and never enter state |
| [kms](modules/kms) | Customer managed KMS key and alias | Automatic key rotation |
| [backup-bucket](modules/backup-bucket) | S3 bucket for backups with lifecycle expiry | Public access blocked, versioning, SSE-KMS |
| [email-dns](modules/email-dns) | SES domain identity, DKIM, MAIL FROM, SPF and DMARC records in Route53 | SPF `-all`, DMARC `quarantine` by default |
| [cloudwatch-alarms](modules/cloudwatch-alarms) | SNS topic and alarms for ECS, ALB 5xx, RDS and Redis | - |
| [github-oidc](modules/github-oidc) | GitHub Actions OIDC provider and deploy role | Trust limited to the `sts.amazonaws.com` audience and the listed repositories; no static keys |

Each module has its own README with the full inputs and outputs tables.

## Usage

[`examples/staging`](examples/staging) composes every module into one environment. A trimmed excerpt:

```hcl
module "network" {
  source = "git::https://github.com/grzegorzszmulik22/terraform-aws-domuris-platform.git//modules/network?ref=v0.2.0"

  project              = "domuris"
  environment          = "staging"
  vpc_cidr             = "10.42.0.0/16"
  public_subnet_cidrs  = ["10.42.0.0/24", "10.42.1.0/24"]
  private_subnet_cidrs = ["10.42.10.0/24", "10.42.11.0/24"]
}

module "kms" {
  source = "git::https://github.com/grzegorzszmulik22/terraform-aws-domuris-platform.git//modules/kms?ref=v0.2.0"

  project     = "domuris"
  environment = "staging"
  alias_name  = "domuris-staging"
}

module "rds" {
  source = "git::https://github.com/grzegorzszmulik22/terraform-aws-domuris-platform.git//modules/rds-postgres?ref=v0.2.0"

  name                       = "domuris-staging"
  vpc_id                     = module.network.vpc_id
  private_subnet_ids         = module.network.private_subnet_ids
  allowed_security_group_ids = [aws_security_group.app_identity.id]
  kms_key_id                 = module.kms.key_id
}
```

Copy `examples/staging/terraform.tfvars.example` to `terraform.tfvars` and supply `redis_auth_token` from a secret store or CI variable.

## Requirements

| Name | Version |
|------|---------|
| Terraform | >= 1.6.0 |
| [hashicorp/aws](https://registry.terraform.io/providers/hashicorp/aws) | >= 6.0 |

## Security defaults

What the code enforces, not what it recommends:

- **Encryption at rest:** RDS storage, Redis, EFS, S3 backups and Secrets Manager require a KMS key input (the example passes the key from the `kms` module, which has rotation enabled); EC2 root volumes are encrypted by default.
- **Encryption in transit:** ALB HTTPS listener uses `ELBSecurityPolicy-TLS13-1-2-2021-06` and HTTP redirects to HTTPS when a certificate is supplied; PostgreSQL sets `rds.force_ssl = 1`; Redis has transit encryption and an AUTH token; EFS mounts use transit encryption.
- **Network isolation:** workloads and data stores run in private subnets without public IPs; data store security groups only accept traffic from the security groups passed in; RDS is not publicly accessible; the backup bucket blocks all public access.
- **Credentials:** the RDS master password is generated and stored by RDS in Secrets Manager; application secrets are injected into ECS tasks from Secrets Manager; CI/CD uses GitHub OIDC rather than access keys; EC2 instances require IMDSv2 and are reached through SSM.
- **Deletion protection:** on by default for RDS (with a final snapshot) and always on for the ALB; KMS keys have a 30-day deletion window by default; secrets have a 7-day recovery window.
- **Edge:** a regional WAF with a per-IP rate limit, the AWS Common Rule Set and Known Bad Inputs is attached to the ALB by default.

See [SECURITY.md](SECURITY.md) for what to review before applying these to a real account.

## Validate locally

```bash
terraform fmt -recursive -check
bash scripts/terraform-validate.sh   # terraform init -backend=false && terraform validate in every module and example
```

No AWS credentials are needed for either command. The same checks run in GitHub Actions on every push and pull request (`.github/workflows/terraform.yml`).

## License

[MIT](LICENSE)
