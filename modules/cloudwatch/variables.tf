variable "name_prefix" { type = string }
variable "alarm_emails" { type = list(string) }
variable "ecs_cluster_name" { type = string }
variable "ecs_service_name" { type = string }
variable "alb_arn_suffix" { type = string }
variable "target_group_suffix" { type = string }
variable "db_cluster_id" { type = string }
variable "redis_cluster_id" { type = string }
