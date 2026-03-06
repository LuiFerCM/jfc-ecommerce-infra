variable "name_prefix" { type = string }
variable "github_org" { type = string }
variable "github_repositories" { type = list(string) }
variable "ecr_repository_arns" { type = list(string) }
variable "ecs_cluster_arn" { type = string }
variable "ecs_service_name" { type = string }
