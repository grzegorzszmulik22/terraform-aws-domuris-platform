variable "name" {
  type        = string
  description = "Database identifier prefix."
}

variable "vpc_id" {
  type        = string
  description = "VPC ID."
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "Private subnet IDs for the DB subnet group."
}

variable "allowed_security_group_ids" {
  type        = list(string)
  description = "Security groups allowed to connect to PostgreSQL."
}

variable "engine_version" {
  type        = string
  description = "PostgreSQL engine version."
  default     = "16.3"
}

variable "instance_class" {
  type        = string
  description = "RDS instance class."
  default     = "db.t4g.micro"
}

variable "allocated_storage" {
  type        = number
  description = "Initial storage in GiB."
  default     = 40
}

variable "max_allocated_storage" {
  type        = number
  description = "Maximum autoscaled storage in GiB."
  default     = 120
}

variable "database_name" {
  type        = string
  description = "Initial database name."
  default     = "domuris"
}

variable "master_username" {
  type        = string
  description = "Master username."
  default     = "domuris_admin"
}

variable "kms_key_id" {
  type        = string
  description = "KMS key ARN or ID for storage encryption."
}

variable "multi_az" {
  type        = bool
  description = "Whether the DB runs in Multi-AZ mode."
  default     = false
}

variable "backup_retention_period" {
  type        = number
  description = "Backup retention period in days."
  default     = 7
}

variable "deletion_protection" {
  type        = bool
  description = "Protect the instance from accidental deletion."
  default     = true
}

variable "skip_final_snapshot" {
  type        = bool
  description = "Skip final snapshot on destroy. Keep false for persistent environments."
  default     = false
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to resources."
  default     = {}
}
