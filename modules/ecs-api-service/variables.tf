variable "name" {
  type        = string
  description = "Name used for the ECS service, task family, IAM roles, and log group."
}

variable "cluster_arn" {
  type        = string
  description = "ECS cluster ARN."
}

variable "vpc_id" {
  type        = string
  description = "VPC ID for the service security group."
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "Private subnet IDs for Fargate tasks."
}

variable "alb_security_group_id" {
  type        = string
  description = "ALB security group allowed to reach the container port."
}

variable "target_group_arn" {
  type        = string
  description = "ALB target group ARN the service registers with."
}

variable "container_image" {
  type        = string
  description = "Container image for the API."
}

variable "additional_security_group_ids" {
  type        = list(string)
  description = "Additional security groups attached to tasks."
  default     = []
}

variable "container_port" {
  type        = number
  description = "Container port exposed to the ALB."
  default     = 8000
}

variable "cpu" {
  type        = number
  description = "Fargate task CPU units."
  default     = 512
}

variable "memory" {
  type        = number
  description = "Fargate task memory in MiB."
  default     = 1024
}

variable "desired_count" {
  type        = number
  description = "Number of running tasks."
  default     = 2
}

variable "environment" {
  type        = map(string)
  description = "Plain environment variables passed to the container."
  default     = {}
}

variable "secret_arns" {
  type        = map(string)
  description = "Secrets Manager ARNs injected as container secrets, keyed by environment variable name."
  default     = {}
}

variable "task_policy_json" {
  type        = string
  description = "Optional IAM policy JSON attached inline to the task role."
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to resources."
  default     = {}
}
