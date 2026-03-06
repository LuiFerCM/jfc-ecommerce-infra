variable "name_prefix" { type = string }

variable "domain_name" {
  type    = string
  default = ""
}

variable "route53_zone_id" {
  type    = string
  default = ""
}

variable "logs_bucket" { type = string }
variable "kms_key_arn" { type = string }
