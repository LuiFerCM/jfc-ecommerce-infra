variable "name_prefix" { type = string }
variable "vpc_cidr" { type = string }
variable "availability_zones" { type = list(string) }
variable "public_subnet_cidrs" { type = list(string) }
variable "app_subnet_cidrs" { type = list(string) }
variable "data_subnet_cidrs" { type = list(string) }
variable "logs_bucket_arn" { type = string }
