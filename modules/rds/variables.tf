variable "name_prefix" { type = string }
variable "vpc_id" { type = string }
variable "data_subnet_ids" { type = list(string) }
variable "app_security_group_id" { type = string }

variable "bastion_security_group_id" {
  type    = string
  default = ""
}

variable "kms_key_arn" { type = string }
variable "db_name" { type = string }
variable "db_master_username" { type = string }

variable "db_master_password" {
  type      = string
  sensitive = true
}

variable "min_capacity" {
  type    = number
  default = 0.5
}

variable "max_capacity" {
  type    = number
  default = 4
}

variable "backup_retention_period" {
  type    = number
  default = 7
}

variable "preferred_maintenance_window" { type = string }
variable "preferred_backup_window" { type = string }

variable "deletion_protection" {
  type    = bool
  default = true
}
