variable "name_prefix" {
  type        = string
  description = "Prefix used for worker instance names and IAM resources."
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where the worker security group is created."
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "Private subnets used to spread worker instances."

  validation {
    condition     = length(var.private_subnet_ids) > 0
    error_message = "At least one private subnet is required."
  }
}

variable "instance_count" {
  type        = number
  description = "Number of worker instances."
  default     = 1

  validation {
    condition     = var.instance_count >= 0
    error_message = "instance_count must be zero or greater."
  }
}

variable "ami_id" {
  type        = string
  description = "Explicit AMI ID. When null, the module searches by ami_name_pattern."
  default     = null
}

variable "ami_name_pattern" {
  type        = string
  description = "AMI name pattern used when ami_id is not supplied."
  default     = "al2023-ami-*-x86_64"
}

variable "ami_owners" {
  type        = list(string)
  description = "AMI owners used when ami_id is not supplied."
  default     = ["amazon"]
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type for document workers."
  default     = "t3.small"
}

variable "key_name" {
  type        = string
  description = "Optional EC2 key pair name. Prefer SSM Session Manager for access."
  default     = null
}

variable "additional_security_group_ids" {
  type        = list(string)
  description = "Additional security groups attached to each worker."
  default     = []
}

variable "user_data_template_path" {
  type        = string
  description = "Optional local template path for bootstrap user data."
  default     = null
}

variable "user_data_vars" {
  type        = map(string)
  description = "Additional variables passed into the user data template."
  default     = {}
}

variable "root_block_device" {
  type = object({
    volume_type           = string
    volume_size           = number
    encrypted             = bool
    kms_key_id            = optional(string)
    delete_on_termination = optional(bool, true)
  })
  description = "Root volume configuration."
  default = {
    volume_type = "gp3"
    volume_size = 40
    encrypted   = true
  }
}

variable "data_volume" {
  type = object({
    device_name = string
    volume_type = string
    volume_size = number
    encrypted   = bool
    kms_key_id  = optional(string)
  })
  description = "Optional attached EBS data volume used for OCR or ingestion scratch space."
  default     = null
}

variable "secrets_arns" {
  type        = list(string)
  description = "Secrets Manager ARNs the worker can read."
  default     = []
}

variable "artifact_bucket_arns" {
  type        = list(string)
  description = "S3 bucket ARNs used for document artifacts or batch inputs."
  default     = []
}

variable "kms_key_arns" {
  type        = list(string)
  description = "KMS key ARNs used to decrypt secrets, S3 objects, or EBS volumes."
  default     = []
}

variable "ebs_optimized" {
  type        = bool
  description = "Whether EBS optimization is enabled for supported instance types."
  default     = true
}

variable "tags" {
  type        = map(string)
  description = "Base tags applied to resources."
  default     = {}
}

variable "worker_tags" {
  type        = map(string)
  description = "Additional tags applied only to worker instances and volumes."
  default     = {}
}
