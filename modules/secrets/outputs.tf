output "secret_arns" {
  description = "Secret ARNs keyed by logical secret name."
  value       = { for name, secret in aws_secretsmanager_secret.this : name => secret.arn }
}

output "secret_names" {
  description = "Secret names keyed by logical secret name."
  value       = { for name, secret in aws_secretsmanager_secret.this : name => secret.name }
}
