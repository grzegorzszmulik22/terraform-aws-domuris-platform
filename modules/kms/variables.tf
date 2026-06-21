variable "project" {
  type        = string
  description = "Project name."
}

variable "environment" {
  type        = string
  description = "Deployment environment."
}

variable "alias_name" {
  type        = string
  description = "KMS alias without the alias/ prefix."
}

variable "deletion_window_in_days" {
  type        = number
  description = "KMS key deletion window."
  default     = 30
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to resources."
  default     = {}
}
