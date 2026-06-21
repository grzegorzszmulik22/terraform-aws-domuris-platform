output "instance_ids" {
  description = "Worker instance IDs."
  value       = aws_instance.worker[*].id
}

output "private_ips" {
  description = "Worker private IP addresses."
  value       = aws_instance.worker[*].private_ip
}

output "instance_names" {
  description = "Worker instance names."
  value       = local.instance_names
}

output "security_group_id" {
  description = "Worker security group ID."
  value       = aws_security_group.worker.id
}

output "instance_profile_name" {
  description = "IAM instance profile name."
  value       = aws_iam_instance_profile.worker.name
}

output "data_volume_ids" {
  description = "Attached data volume IDs."
  value       = aws_ebs_volume.data[*].id
}
