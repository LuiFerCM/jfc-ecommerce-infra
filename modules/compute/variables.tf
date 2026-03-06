variable "name_prefix" { type = string }
variable "aws_region" { type = string }
variable "vpc_id" { type = string }
variable "app_subnet_ids" { type = list(string) }
variable "ecs_security_group_id" { type = string }
variable "target_group_arn" { type = string }
variable "alb_arn_suffix" { type = string }
variable "target_group_arn_suffix" { type = string }

variable "container_image" {
  type    = string
  default = ""
}

variable "container_port" { type = number }
variable "container_cpu" { type = number }
variable "container_memory" { type = number }
variable "desired_count" { type = number }
variable "min_capacity" { type = number }
variable "max_capacity" { type = number }
variable "cpu_target_value" { type = number }
variable "memory_target_value" { type = number }
variable "kms_key_arn" { type = string }
variable "db_secret_arn" { type = string }
variable "redis_endpoint" { type = string }
variable "db_endpoint" { type = string }

variable "enable_container_insights" {
  type    = bool
  default = true
}
