variable "name" {
  type        = string
  description = "Cache name prefix."
}

variable "vpc_id" {
  type        = string
  description = "VPC ID."
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "Private subnet IDs for Redis."
}

variable "allowed_security_group_ids" {
  type        = list(string)
  description = "Security groups allowed to connect to Redis."
}

variable "node_type" {
  type        = string
  description = "ElastiCache node type."
  default     = "cache.t4g.micro"
}

variable "engine_version" {
  type        = string
  description = "Redis engine version."
  default     = "7.1"
}

variable "replicas_per_node_group" {
  type        = number
  description = "Replica count for the single Redis shard."
  default     = 0
}

variable "kms_key_id" {
  type        = string
  description = "KMS key ARN or ID for at-rest encryption."
}

variable "auth_token" {
  type        = string
  description = "Redis AUTH token."
  sensitive   = true
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to resources."
  default     = {}
}
