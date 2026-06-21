variable "project" {
  type        = string
  description = "Project name used in resource names."
}

variable "environment" {
  type        = string
  description = "Deployment environment."

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC."
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for public subnets."
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for private subnets."
}

variable "enable_nat_gateway" {
  type        = bool
  description = "Whether private subnets should route through a NAT gateway."
  default     = true
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to all supported resources."
  default     = {}
}
