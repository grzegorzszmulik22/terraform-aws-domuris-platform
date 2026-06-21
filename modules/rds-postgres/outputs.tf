output "instance_id" {
  description = "RDS instance identifier."
  value       = aws_db_instance.this.id
}

output "endpoint" {
  description = "RDS endpoint."
  value       = aws_db_instance.this.address
}

output "port" {
  description = "RDS port."
  value       = aws_db_instance.this.port
}

output "security_group_id" {
  description = "RDS security group ID."
  value       = aws_security_group.postgres.id
}

output "master_user_secret_arn" {
  description = "Secrets Manager ARN for the managed master password."
  value       = aws_db_instance.this.master_user_secret[0].secret_arn
}
