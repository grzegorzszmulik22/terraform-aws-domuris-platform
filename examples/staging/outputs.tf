output "alb_dns_name" {
  description = "Application load balancer DNS name."
  value       = module.alb.alb_dns_name
}

output "api_service_name" {
  description = "API ECS service name."
  value       = module.api.service_name
}

output "worker_service_name" {
  description = "Worker ECS service name."
  value       = module.worker.service_name
}

output "qdrant_service_name" {
  description = "Qdrant ECS service name."
  value       = module.qdrant.service_name
}

output "document_worker_instance_names" {
  description = "EC2 document worker instance names."
  value       = module.document_worker_fleet.instance_names
}

output "alarm_topic_arn" {
  description = "SNS alarm topic ARN."
  value       = module.alarms.topic_arn
}
