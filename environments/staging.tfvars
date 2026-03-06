# =============================================================================
# JFC E-Commerce - Staging Environment (Cost-Optimized)
# =============================================================================
environment = "staging"
aws_region  = "us-east-1"

# Networking
vpc_cidr            = "10.1.0.0/16"
availability_zones  = ["us-east-1a", "us-east-1b"]
public_subnet_cidrs = ["10.1.1.0/24", "10.1.2.0/24"]
app_subnet_cidrs    = ["10.1.10.0/24", "10.1.11.0/24"]
data_subnet_cidrs   = ["10.1.20.0/24", "10.1.21.0/24"]

# Compute (smaller for staging)
container_port      = 8080
container_cpu       = 256
container_memory    = 512
desired_count       = 1
min_capacity        = 1
max_capacity        = 3
cpu_target_value    = 75
memory_target_value = 80

# Database (minimal for staging)
db_min_capacity        = 0.5
db_max_capacity        = 2
db_deletion_protection = false

# Security (WAF off for staging to save costs)
enable_waf        = false
enable_cloudtrail = false

# Bastion
enable_bastion = true

# Budget
monthly_budget_amount = 200
