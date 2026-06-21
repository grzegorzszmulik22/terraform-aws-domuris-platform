variable "name" {
  type        = string
  description = "Load balancer name prefix."
}

variable "vpc_id" {
  type        = string
  description = "VPC ID."
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "Public subnet IDs for the ALB."
}

variable "certificate_arn" {
  type        = string
  description = "ACM certificate ARN. When null, the module creates HTTP only."
  default     = null
}

variable "health_check_path" {
  type        = string
  description = "Application health check path."
  default     = "/health"
}

variable "enable_waf" {
  type        = bool
  description = "Create and attach a regional WAF web ACL."
  default     = true
}

variable "waf_rate_limit" {
  type        = number
  description = "Maximum requests per five-minute window per source IP."
  default     = 2000
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to resources."
  default     = {}
}
