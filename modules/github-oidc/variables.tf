variable "role_name" {
  type        = string
  description = "IAM role name for GitHub Actions."
}

variable "github_owner" {
  type        = string
  description = "GitHub organization or user."
}

variable "repositories" {
  type        = list(string)
  description = "Repository names allowed to assume the role."
}

variable "policy_json" {
  type        = string
  description = "Least-privilege IAM policy JSON attached to the role."
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to supported resources."
  default     = {}
}
