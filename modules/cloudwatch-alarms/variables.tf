variable "name" {
  type        = string
  description = "Alarm name prefix."
}

variable "ecs_cluster_name" {
  type        = string
  description = "ECS cluster name."
}

variable "ecs_service_names" {
  type        = list(string)
  description = "ECS services monitored for CPU and memory."
  default     = []
}

variable "alb_arn_suffix" {
  type        = string
  description = "ALB ARN suffix for ApplicationELB metrics."
  default     = null
}

variable "target_group_arn_suffix" {
  type        = string
  description = "Target group ARN suffix for ApplicationELB metrics."
  default     = null
}

variable "rds_instance_id" {
  type        = string
  description = "RDS instance identifier."
  default     = null
}

variable "redis_replication_group_id" {
  type        = string
  description = "ElastiCache replication group identifier."
  default     = null
}

variable "notification_email_endpoints" {
  type        = list(string)
  description = "Email endpoints subscribed to the alarm SNS topic."
  default     = []
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to supported resources."
  default     = {}
}
