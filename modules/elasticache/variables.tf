variable "name_prefix" { type = string }
variable "vpc_id" { type = string }
variable "data_subnet_ids" { type = list(string) }
variable "app_security_group_id" { type = string }
variable "node_type" { type = string }
variable "num_cache_nodes" { type = number }
variable "engine_version" { type = string }
variable "kms_key_arn" { type = string }
