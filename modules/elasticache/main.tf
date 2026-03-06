resource "aws_elasticache_subnet_group" "main" {
  name       = "${var.name_prefix}-redis-subnet"
  subnet_ids = var.data_subnet_ids
}

resource "aws_security_group" "redis" {
  name_prefix = "${var.name_prefix}-redis-"
  vpc_id      = var.vpc_id
  description = "ElastiCache Redis security group"
  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [var.app_security_group_id]
    description     = "Redis from app tier"
  }
  tags = { Name = "${var.name_prefix}-redis-sg" }
  lifecycle { create_before_destroy = true }
}

resource "aws_elasticache_cluster" "main" {
  cluster_id           = "${var.name_prefix}-redis"
  engine               = "redis"
  engine_version       = var.engine_version
  node_type            = var.node_type
  num_cache_nodes      = var.num_cache_nodes
  parameter_group_name = "default.redis7"
  subnet_group_name    = aws_elasticache_subnet_group.main.name
  security_group_ids   = [aws_security_group.redis.id]
  port                 = 6379

  snapshot_retention_limit = 5
  snapshot_window          = "02:00-03:00"
  maintenance_window       = "sun:05:00-sun:06:00"

  tags = { Name = "${var.name_prefix}-redis" }
}
