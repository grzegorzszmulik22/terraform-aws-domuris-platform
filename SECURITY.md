# Security Notes

Before applying these modules against an AWS account, review:

- IAM policies and OIDC trust conditions for the exact repositories and branches that should deploy
- WAF rule actions, rate limits, and any false positives for application traffic
- RDS deletion protection, backup retention, and final snapshot requirements per environment
- Redis auth token rotation and how sensitive values enter Terraform state
- Secrets Manager ownership, rotation, and application bootstrap process
- CloudWatch alarm thresholds, notification endpoints, and escalation paths
- Whether the EC2 worker fleet is still required or can be retired in favor of ECS jobs

Do not commit state files, real tfvars files, account IDs, tenant data, secrets, or production domain values.
