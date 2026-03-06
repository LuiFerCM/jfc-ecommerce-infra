# =============================================================================
# JFC E-Commerce - Production Environment
# =============================================================================
environment = "prod"
aws_region  = "us-east-1"

# Networking
vpc_cidr            = "10.0.0.0/16"
availability_zones  = ["us-east-1a", "us-east-1b"]
public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
app_subnet_cidrs    = ["10.0.10.0/24", "10.0.11.0/24"]
data_subnet_cidrs   = ["10.0.20.0/24", "10.0.21.0/24"]

# DNS (update with your values)
domain_name               = ""  # e.g., "jfc-ecommerce.com"
subject_alternative_names = []  # e.g., ["*.jfc-ecommerce.com"]
route53_zone_id           = ""  # e.g., "Z1234567890ABC"

# Compute
container_port      = 8080
container_cpu       = 512
container_memory    = 1024
desired_count       = 2
min_capacity        = 2
max_capacity        = 10
cpu_target_value    = 70
memory_target_value = 75

# Database (Aurora Serverless v2)
db_name                         = "ecommerce"
db_master_username              = "dbadmin"
db_min_capacity                 = 0.5
db_max_capacity                 = 4
db_backup_retention_period      = 7
db_preferred_maintenance_window = "sun:04:00-sun:05:00"
db_preferred_backup_window      = "03:00-04:00"
db_deletion_protection          = true

# Redis
redis_node_type       = "cache.t4g.micro"
redis_num_cache_nodes = 1
redis_engine_version  = "7.1"

# Monitoring
alarm_emails              = []  # ["ops@jfc-ecommerce.com"]
enable_container_insights = true

# Security
enable_waf      = true
waf_rate_limit  = 2000
enable_cloudtrail = true

# CI/CD
enable_cicd         = true
github_org          = ""  # Your GitHub org/username
github_repositories = []  # ["backend-api", "frontend-app"]

# Budget
monthly_budget_amount = 600
budget_alert_emails   = []  # ["finance@jfc-ecommerce.com"]

# Bastion
enable_bastion       = true
bastion_instance_type = "t3.micro"
bastion_key_name     = ""  # Your EC2 key pair name
