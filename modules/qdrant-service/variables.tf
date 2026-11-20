variable "name" {
  type        = string
  description = "Name prefix for the Qdrant service, task family, IAM roles, and EFS resources."
}

variable "cluster_arn" {
  type        = string
  description = "ECS cluster ARN."
}

variable "vpc_id" {
  type        = string
  description = "VPC ID for the Qdrant and EFS security groups."
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "Private subnet IDs for Fargate tasks and EFS mount targets."
}

variable "allowed_security_group_ids" {
  type        = list(string)
  description = "Security groups allowed to reach Qdrant on ports 6333 (HTTP) and 6334 (gRPC)."
}

variable "service_discovery_namespace_id" {
  type        = string
  description = "Optional Cloud Map private DNS namespace ID."
  default     = null
}

variable "service_discovery_name" {
  type        = string
  description = "Cloud Map service name used when service_discovery_namespace_id is set."
  default     = "qdrant"
}

variable "container_image" {
  type        = string
  description = "Qdrant container image."
  default     = "qdrant/qdrant:v1.12.4"
}

variable "cpu" {
  type        = number
  description = "Fargate task CPU units."
  default     = 1024
}

variable "memory" {
  type        = number
  description = "Fargate task memory in MiB."
  default     = 2048
}

variable "desired_count" {
  type        = number
  description = "Number of running tasks. Qdrant uses a single EFS-backed volume, so keep this at 1."
  default     = 1
}

variable "kms_key_id" {
  type        = string
  description = "KMS key ARN or ID for EFS encryption."
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to resources."
  default     = {}
}
