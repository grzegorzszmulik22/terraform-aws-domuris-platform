variable "aws_region" {
  type        = string
  description = "AWS region."
  default     = "eu-central-1"
}

variable "project" {
  type        = string
  description = "Project name."
  default     = "domuris"
}

variable "environment" {
  type        = string
  description = "Environment name."
  default     = "staging"
}

variable "domain_name" {
  type        = string
  description = "Application domain name."
  default     = "staging.example.com"
}

variable "route53_zone_id" {
  type        = string
  description = "Optional Route53 zone ID for the application domain."
  default     = null
}

variable "certificate_arn" {
  type        = string
  description = "Optional ACM certificate ARN for HTTPS."
  default     = null
}

variable "api_image" {
  type        = string
  description = "Container image for the Domuris API."
  default     = "registry.example.com/domuris/api:staging"
}

variable "worker_image" {
  type        = string
  description = "Container image for async workers."
  default     = "registry.example.com/domuris/api:staging"
}

variable "redis_auth_token" {
  type        = string
  description = "Redis auth token supplied by CI or a secret backend."
  sensitive   = true

  validation {
    condition     = length(var.redis_auth_token) >= 16
    error_message = "redis_auth_token must be at least 16 characters."
  }
}

variable "notification_email_endpoints" {
  type        = list(string)
  description = "Optional alarm notification email endpoints."
  default     = []
}
