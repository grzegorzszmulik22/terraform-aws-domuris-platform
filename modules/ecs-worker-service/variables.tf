variable "name" { type = string }
variable "cluster_arn" { type = string }
variable "vpc_id" { type = string }
variable "private_subnet_ids" { type = list(string) }
variable "container_image" { type = string }

variable "additional_security_group_ids" {
  type    = list(string)
  default = []
}

variable "command" {
  type    = list(string)
  default = []
}

variable "cpu" {
  type    = number
  default = 512
}

variable "memory" {
  type    = number
  default = 1024
}

variable "desired_count" {
  type    = number
  default = 1
}

variable "environment" {
  type    = map(string)
  default = {}
}

variable "secret_arns" {
  type    = map(string)
  default = {}
}

variable "task_policy_json" {
  type    = string
  default = null
}

variable "tags" {
  type    = map(string)
  default = {}
}
