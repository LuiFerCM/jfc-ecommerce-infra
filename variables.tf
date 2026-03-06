# =============================================================================
# General
# =============================================================================
variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
  default     = "jfc-ecommerce"
}

variable "environment" {
  description = "Environment name (prod, staging, dev)"
  type        = string
}

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

# =============================================================================
# Networking
# =============================================================================
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of AZs to use"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "app_subnet_cidrs" {
  description = "CIDR blocks for application subnets"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.11.0/24"]
}

variable "data_subnet_cidrs" {
  description = "CIDR blocks for data subnets"
  type        = list(string)
  default     = ["10.0.20.0/24", "10.0.21.0/24"]
}

# =============================================================================
# DNS & SSL
# =============================================================================
variable "domain_name" {
  description = "Domain name for the application"
  type        = string
  default     = ""
}

variable "subject_alternative_names" {
  description = "SANs for the SSL certificate"
  type        = list(string)
  default     = []
}

variable "route53_zone_id" {
  description = "Route53 hosted zone ID"
  type        = string
  default     = ""
}

# =============================================================================
# Compute (ECS Fargate)
# =============================================================================
variable "container_image" {
  description = "Docker image for the backend API"
  type        = string
  default     = ""
}

variable "container_port" {
  description = "Port exposed by the container"
  type        = number
  default     = 8080
}

variable "container_cpu" {
  description = "CPU units for the task (1 vCPU = 1024)"
  type        = number
  default     = 512
}

variable "container_memory" {
  description = "Memory (MiB) for the task"
  type        = number
  default     = 1024
}

variable "desired_count" {
  description = "Desired number of ECS tasks"
  type        = number
  default     = 2
}

variable "min_capacity" {
  description = "Min tasks for auto-scaling"
  type        = number
  default     = 2
}

variable "max_capacity" {
  description = "Max tasks for auto-scaling"
  type        = number
  default     = 10
}

variable "cpu_target_value" {
  description = "CPU target for auto-scaling (%)"
  type        = number
  default     = 70
}

variable "memory_target_value" {
  description = "Memory target for auto-scaling (%)"
  type        = number
  default     = 75
}

# =============================================================================
# Database (RDS Aurora Serverless v2)
# =============================================================================
variable "db_name" {
  description = "Database name"
  type        = string
  default     = "ecommerce"
}

variable "db_master_username" {
  description = "Master username for the database"
  type        = string
  default     = "dbadmin"
}

variable "db_min_capacity" {
  description = "Minimum ACU for Aurora Serverless v2"
  type        = number
  default     = 0.5
}

variable "db_max_capacity" {
  description = "Maximum ACU for Aurora Serverless v2"
  type        = number
  default     = 4
}

variable "db_backup_retention_period" {
  description = "Backup retention in days"
  type        = number
  default     = 7
}

variable "db_preferred_maintenance_window" {
  description = "Preferred maintenance window"
  type        = string
  default     = "sun:04:00-sun:05:00"
}

variable "db_preferred_backup_window" {
  description = "Preferred backup window"
  type        = string
  default     = "03:00-04:00"
}

variable "db_deletion_protection" {
  description = "Enable deletion protection"
  type        = bool
  default     = true
}

# =============================================================================
# ElastiCache (Redis)
# =============================================================================
variable "redis_node_type" {
  description = "ElastiCache Redis node type"
  type        = string
  default     = "cache.t4g.micro"
}

variable "redis_num_cache_nodes" {
  description = "Number of cache nodes"
  type        = number
  default     = 1
}

variable "redis_engine_version" {
  description = "Redis engine version"
  type        = string
  default     = "7.1"
}

# =============================================================================
# Monitoring & Alerts
# =============================================================================
variable "alarm_emails" {
  description = "Email addresses for alarm notifications"
  type        = list(string)
  default     = []
}

variable "enable_container_insights" {
  description = "Enable ECS Container Insights"
  type        = bool
  default     = true
}

# =============================================================================
# Security
# =============================================================================
variable "enable_waf" {
  description = "Enable WAF for ALB"
  type        = bool
  default     = true
}

variable "waf_rate_limit" {
  description = "WAF rate limit (requests per 5 min)"
  type        = number
  default     = 2000
}

variable "enable_cloudtrail" {
  description = "Enable CloudTrail audit logging"
  type        = bool
  default     = true
}

# =============================================================================
# CI/CD
# =============================================================================
variable "enable_cicd" {
  description = "Enable GitHub Actions OIDC integration"
  type        = bool
  default     = true
}

variable "github_org" {
  description = "GitHub organization or username"
  type        = string
  default     = ""
}

variable "github_repositories" {
  description = "List of GitHub repos allowed for OIDC"
  type        = list(string)
  default     = []
}

# =============================================================================
# Budgets
# =============================================================================
variable "monthly_budget_amount" {
  description = "Monthly budget in USD"
  type        = number
  default     = 600
}

variable "budget_alert_emails" {
  description = "Emails for budget alerts"
  type        = list(string)
  default     = []
}

# =============================================================================
# Bastion
# =============================================================================
variable "enable_bastion" {
  description = "Enable bastion host"
  type        = bool
  default     = true
}

variable "bastion_instance_type" {
  description = "EC2 instance type for bastion"
  type        = string
  default     = "t3.micro"
}

variable "bastion_key_name" {
  description = "EC2 key pair name for bastion"
  type        = string
  default     = ""
}
