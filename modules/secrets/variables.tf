variable "project" {
  type        = string
  description = "Project name."
}

variable "environment" {
  type        = string
  description = "Deployment environment."
}

variable "kms_key_id" {
  type        = string
  description = "KMS key used for Secrets Manager encryption."
}

variable "secret_names" {
  type        = set(string)
  description = "Logical secret names to create. Values are not managed here."
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to resources."
  default     = {}
}
