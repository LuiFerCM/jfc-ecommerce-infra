# =============================================================================
# Networking
# =============================================================================
output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

# =============================================================================
# Load Balancer
# =============================================================================
output "alb_dns_name" {
  description = "ALB DNS name"
  value       = module.alb.dns_name
}

# =============================================================================
# Frontend
# =============================================================================
output "frontend_url" {
  description = "CloudFront distribution URL"
  value       = module.frontend.cloudfront_domain_name
}

output "frontend_bucket" {
  description = "S3 bucket for frontend deployment"
  value       = module.frontend.bucket_name
}

# =============================================================================
# Database
# =============================================================================
output "db_cluster_endpoint" {
  description = "Aurora cluster endpoint"
  value       = module.rds.cluster_endpoint
  sensitive   = true
}

output "db_reader_endpoint" {
  description = "Aurora reader endpoint"
  value       = module.rds.reader_endpoint
  sensitive   = true
}

# =============================================================================
# Cache
# =============================================================================
output "redis_endpoint" {
  description = "Redis endpoint"
  value       = module.elasticache.endpoint
  sensitive   = true
}

# =============================================================================
# Compute
# =============================================================================
output "ecs_security_group_id" {
  description = "ECS tasks security group ID"
  value       = aws_security_group.ecs.id
}

output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = module.compute.cluster_name
}

output "ecr_repository_urls" {
  description = "ECR repository URLs"
  value       = module.compute.ecr_repository_urls
}

# =============================================================================
# CI/CD
# =============================================================================
output "github_actions_role_arn" {
  description = "IAM role ARN for GitHub Actions"
  value       = var.enable_cicd ? module.cicd[0].role_arn : "CI/CD disabled"
}

# =============================================================================
# Bastion
# =============================================================================
output "bastion_public_ip" {
  description = "Bastion host public IP"
  value       = var.enable_bastion ? module.bastion[0].public_ip : "Bastion disabled"
}
