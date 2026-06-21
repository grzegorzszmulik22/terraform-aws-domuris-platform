output "role_arn" {
  description = "GitHub Actions role ARN."
  value       = aws_iam_role.this.arn
}

output "provider_arn" {
  description = "GitHub OIDC provider ARN."
  value       = aws_iam_openid_connect_provider.github.arn
}
