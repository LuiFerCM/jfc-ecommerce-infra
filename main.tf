# =============================================================================
# Local Values
# =============================================================================
locals {
  name_prefix = "${var.project_name}-${var.environment}"
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

# =============================================================================
# KMS - Encryption Keys (created first, used by other modules)
# =============================================================================
module "kms" {
  source      = "./modules/kms"
  name_prefix = local.name_prefix
}

# =============================================================================
# Logs Bucket - Centralized Logging
# =============================================================================
module "logs_bucket" {
  source      = "./modules/logs-bucket"
  name_prefix = local.name_prefix
  kms_key_arn = module.kms.key_arn
}

# =============================================================================
# VPC - Networking
# =============================================================================
module "vpc" {
  source              = "./modules/vpc"
  name_prefix         = local.name_prefix
  vpc_cidr            = var.vpc_cidr
  availability_zones  = var.availability_zones
  public_subnet_cidrs = var.public_subnet_cidrs
  app_subnet_cidrs    = var.app_subnet_cidrs
  data_subnet_cidrs   = var.data_subnet_cidrs
  logs_bucket_arn     = module.logs_bucket.bucket_arn
}

# =============================================================================
# Secrets Manager
# =============================================================================
module "secrets" {
  source      = "./modules/secrets"
  name_prefix = local.name_prefix
  kms_key_arn = module.kms.key_arn
  db_name     = var.db_name
  db_username = var.db_master_username
}

# =============================================================================
# ALB - Application Load Balancer
# =============================================================================
module "alb" {
  source            = "./modules/alb"
  name_prefix       = local.name_prefix
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  container_port    = var.container_port
  logs_bucket_id    = module.logs_bucket.bucket_id
  domain_name       = var.domain_name
  route53_zone_id   = var.route53_zone_id
  san               = var.subject_alternative_names
}

# =============================================================================
# ECS Security Group (root-level to break circular dependency)
# =============================================================================
resource "aws_security_group" "ecs" {
  name_prefix = "${local.name_prefix}-ecs-"
  vpc_id      = module.vpc.vpc_id
  description = "ECS tasks security group"

  ingress {
    from_port       = var.container_port
    to_port         = var.container_port
    protocol        = "tcp"
    security_groups = [module.alb.security_group_id]
    description     = "From ALB"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound"
  }
  tags = { Name = "${local.name_prefix}-ecs-sg" }
  lifecycle { create_before_destroy = true }
}

# =============================================================================
# WAF - Web Application Firewall
# =============================================================================
module "waf" {
  count       = var.enable_waf ? 1 : 0
  source      = "./modules/waf"
  name_prefix = local.name_prefix
  alb_arn     = module.alb.alb_arn
  rate_limit  = var.waf_rate_limit
}

# =============================================================================
# RDS Aurora Serverless v2
# =============================================================================
module "rds" {
  source                       = "./modules/rds"
  name_prefix                  = local.name_prefix
  vpc_id                       = module.vpc.vpc_id
  data_subnet_ids              = module.vpc.data_subnet_ids
  app_security_group_id        = aws_security_group.ecs.id
  bastion_security_group_id    = var.enable_bastion ? module.bastion[0].security_group_id : ""
  kms_key_arn                  = module.kms.key_arn
  db_name                      = var.db_name
  db_master_username           = var.db_master_username
  db_master_password           = module.secrets.db_password
  min_capacity                 = var.db_min_capacity
  max_capacity                 = var.db_max_capacity
  backup_retention_period      = var.db_backup_retention_period
  preferred_maintenance_window = var.db_preferred_maintenance_window
  preferred_backup_window      = var.db_preferred_backup_window
  deletion_protection          = var.db_deletion_protection
}

# =============================================================================
# ElastiCache Redis
# =============================================================================
module "elasticache" {
  source                = "./modules/elasticache"
  name_prefix           = local.name_prefix
  vpc_id                = module.vpc.vpc_id
  data_subnet_ids       = module.vpc.data_subnet_ids
  app_security_group_id = aws_security_group.ecs.id
  node_type             = var.redis_node_type
  num_cache_nodes       = var.redis_num_cache_nodes
  engine_version        = var.redis_engine_version
  kms_key_arn           = module.kms.key_arn
}

# =============================================================================
# Compute - ECS Fargate
# =============================================================================
module "compute" {
  source                    = "./modules/compute"
  name_prefix               = local.name_prefix
  aws_region                = var.aws_region
  vpc_id                    = module.vpc.vpc_id
  app_subnet_ids            = module.vpc.app_subnet_ids
  ecs_security_group_id     = aws_security_group.ecs.id
  target_group_arn          = module.alb.target_group_arn
  alb_arn_suffix            = module.alb.alb_arn_suffix
  target_group_arn_suffix   = module.alb.target_group_arn_suffix
  container_image           = var.container_image
  container_port            = var.container_port
  container_cpu             = var.container_cpu
  container_memory          = var.container_memory
  desired_count             = var.desired_count
  min_capacity              = var.min_capacity
  max_capacity              = var.max_capacity
  cpu_target_value          = var.cpu_target_value
  memory_target_value       = var.memory_target_value
  kms_key_arn               = module.kms.key_arn
  db_secret_arn             = module.secrets.db_secret_arn
  redis_endpoint            = module.elasticache.endpoint
  db_endpoint               = module.rds.cluster_endpoint
  enable_container_insights = var.enable_container_insights
}

# =============================================================================
# Frontend - S3 + CloudFront
# =============================================================================
module "frontend" {
  source          = "./modules/frontend"
  name_prefix     = local.name_prefix
  domain_name     = var.domain_name
  route53_zone_id = var.route53_zone_id
  logs_bucket     = module.logs_bucket.bucket_domain_name
  kms_key_arn     = module.kms.key_arn

  providers = {
    aws           = aws
    aws.us_east_1 = aws.us_east_1
  }
}

# =============================================================================
# CloudWatch - Monitoring, Alarms & Dashboard
# =============================================================================
module "cloudwatch" {
  source              = "./modules/cloudwatch"
  name_prefix         = local.name_prefix
  alarm_emails        = var.alarm_emails
  ecs_cluster_name    = module.compute.cluster_name
  ecs_service_name    = module.compute.service_name
  alb_arn_suffix      = module.alb.alb_arn_suffix
  target_group_suffix = module.alb.target_group_arn_suffix
  db_cluster_id       = module.rds.cluster_identifier
  redis_cluster_id    = module.elasticache.cluster_id
}

# =============================================================================
# CloudTrail - Audit Logging
# =============================================================================
module "cloudtrail" {
  count           = var.enable_cloudtrail ? 1 : 0
  source          = "./modules/cloudtrail"
  name_prefix     = local.name_prefix
  logs_bucket_id  = module.logs_bucket.bucket_id
  logs_bucket_arn = module.logs_bucket.bucket_arn
  kms_key_arn     = module.kms.key_arn
}

# =============================================================================
# Bastion Host
# =============================================================================
module "bastion" {
  count            = var.enable_bastion ? 1 : 0
  source           = "./modules/bastion"
  name_prefix      = local.name_prefix
  vpc_id           = module.vpc.vpc_id
  public_subnet_id = module.vpc.public_subnet_ids[0]
  instance_type    = var.bastion_instance_type
  key_name         = var.bastion_key_name
}

# =============================================================================
# CI/CD - GitHub Actions OIDC
# =============================================================================
module "cicd" {
  count               = var.enable_cicd ? 1 : 0
  source              = "./modules/cicd"
  name_prefix         = local.name_prefix
  github_org          = var.github_org
  github_repositories = var.github_repositories
  ecr_repository_arns = module.compute.ecr_repository_arns
  ecs_cluster_arn     = module.compute.cluster_arn
  ecs_service_name    = module.compute.service_name
}

# =============================================================================
# Budgets - Cost Management
# =============================================================================
module "budgets" {
  source         = "./modules/budgets"
  name_prefix    = local.name_prefix
  monthly_amount = var.monthly_budget_amount
  alert_emails   = var.budget_alert_emails
}
