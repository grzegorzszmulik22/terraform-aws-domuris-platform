variable "name" { type = string }
variable "cluster_arn" { type = string }
variable "vpc_id" { type = string }
variable "private_subnet_ids" { type = list(string) }
variable "allowed_security_group_ids" { type = list(string) }

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
  type    = string
  default = "qdrant/qdrant:v1.12.4"
}

variable "cpu" {
  type    = number
  default = 1024
}

variable "memory" {
  type    = number
  default = 2048
}

variable "desired_count" {
  type    = number
  default = 1
}

variable "kms_key_id" {
  type        = string
  description = "KMS key ARN or ID for EFS encryption."
}

variable "tags" {
  type    = map(string)
  default = {}
}
