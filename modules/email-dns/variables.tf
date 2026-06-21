variable "domain_name" {
  type        = string
  description = "Domain verified for application email."
}

variable "zone_id" {
  type        = string
  description = "Route53 hosted zone ID for domain_name."
}

variable "mail_from_subdomain" {
  type        = string
  description = "MAIL FROM subdomain."
  default     = "mail"
}

variable "dmarc_policy" {
  type        = string
  description = "DMARC policy."
  default     = "quarantine"

  validation {
    condition     = contains(["none", "quarantine", "reject"], var.dmarc_policy)
    error_message = "dmarc_policy must be none, quarantine, or reject."
  }
}

variable "dmarc_reports_email" {
  type        = string
  description = "Optional aggregate report email address."
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to supported resources."
  default     = {}
}
