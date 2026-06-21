# terraform-aws-domuris-platform

Terraform modules for the AWS platform layer behind a property-management SaaS.

## Scope

- Private VPC layout with public ALB subnets and private application/data subnets
- ECS Fargate API and background worker services
- Optional EC2 document worker fleet for migration-heavy or host-based workloads
- RDS PostgreSQL with managed master password, encrypted storage, SSL enforcement, log exports, and deletion protection
- Redis with TLS, auth token support, KMS encryption, snapshots, and private ingress
- Internal Qdrant vector search service on ECS with encrypted EFS persistence and Cloud Map discovery
- Secrets Manager, KMS, encrypted S3 backups, WAF, Route53 records, SES email DNS, and CloudWatch alarms
- GitHub Actions OIDC module for short-lived CI/CD credentials

## Layout

```text
modules/
  app-load-balancer/      Public ALB, HTTPS redirect, target group, WAF
  backup-bucket/          Encrypted S3 bucket with versioning and lifecycle policy
  cloudwatch-alarms/      ECS, ALB, RDS, and Redis alarms with SNS notifications
  document-worker-fleet/  Private EC2 fleet with SSM, encrypted disks, and drift controls
  ecs-api-service/        ECS Fargate API service behind the ALB
  ecs-worker-service/     ECS Fargate async worker service
  email-dns/              SES identity, DKIM, SPF, MAIL FROM, and DMARC records
  github-oidc/            GitHub Actions federated IAM role
  kms/                    Rotating KMS key and alias
  network/                VPC, public/private subnets, routing, NAT
  qdrant-service/         Internal vector database service on ECS and EFS
  rds-postgres/           Private PostgreSQL database
  redis-cache/            Private Redis replication group

examples/
  staging/                End-to-end composition for a staging environment
```

## Notes

The `document-worker-fleet` module covers host-based work that does not fit cleanly into the ECS runtime: migrations, document ingestion, scheduled maintenance, or vendor tooling that expects a long-lived instance. It uses counted EC2 instances, AMI lookup, private subnet placement, encrypted root and data volumes, SSM access, merged tag layers, and explicit lifecycle drift handling.

The default path for API and async workloads is ECS Fargate. EC2 is kept narrow and operationally explicit.

## CI/CD

GitHub Actions runs formatting and validation across every Terraform directory. Module releases are tagged manually after validation. Live deployments should consume these modules through pinned Git refs and use OIDC instead of static AWS keys.

Terraform state, production variables, generated provider directories, and credentials do not belong in this repository.

## Local Checks

```bash
terraform fmt -recursive -check
```

To validate modules and examples, run `terraform init -backend=false` in the target directory first. Review account-specific controls and environment variables before planning or applying live changes.
