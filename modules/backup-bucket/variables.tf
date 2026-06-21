variable "bucket_name" {
  type        = string
  description = "Globally unique S3 bucket name."
}

variable "kms_key_arn" {
  type        = string
  description = "KMS key ARN for bucket encryption."
}

variable "retention_days" {
  type        = number
  description = "Days before backup objects expire."
  default     = 90
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to resources."
  default     = {}
}
