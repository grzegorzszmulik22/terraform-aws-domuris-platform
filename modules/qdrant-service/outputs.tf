output "service_name" {
  description = "ECS service name."
  value       = aws_ecs_service.this.name
}

output "security_group_id" {
  description = "Qdrant service security group ID."
  value       = aws_security_group.qdrant.id
}

output "efs_file_system_id" {
  description = "Qdrant EFS file system ID."
  value       = aws_efs_file_system.this.id
}

output "log_group_name" {
  description = "CloudWatch log group name."
  value       = aws_cloudwatch_log_group.this.name
}

output "service_discovery_name" {
  description = "Cloud Map service name, when enabled."
  value       = try(aws_service_discovery_service.this[0].name, null)
}
