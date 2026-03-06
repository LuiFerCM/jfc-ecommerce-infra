variable "name_prefix" { type = string }
variable "vpc_id" { type = string }
variable "public_subnet_ids" { type = list(string) }
variable "container_port" { type = number }
variable "logs_bucket_id" { type = string }

variable "domain_name" {
  type    = string
  default = ""
}

variable "route53_zone_id" {
  type    = string
  default = ""
}

variable "san" {
  type    = list(string)
  default = []
}
