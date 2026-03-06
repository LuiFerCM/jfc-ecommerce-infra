resource "aws_db_subnet_group" "main" {
  name       = "${var.name_prefix}-db-subnet"
  subnet_ids = var.data_subnet_ids
  tags       = { Name = "${var.name_prefix}-db-subnet-group" }
}

resource "aws_security_group" "rds" {
  name_prefix = "${var.name_prefix}-rds-"
  vpc_id      = var.vpc_id
  description = "RDS Aurora security group"

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = compact([var.app_security_group_id, var.bastion_security_group_id])
    description     = "PostgreSQL from app and bastion"
  }
  tags = { Name = "${var.name_prefix}-rds-sg" }
  lifecycle { create_before_destroy = true }
}

resource "aws_rds_cluster" "main" {
  cluster_identifier          = "${var.name_prefix}-aurora"
  engine                      = "aurora-postgresql"
  engine_mode                 = "provisioned"
  engine_version              = "16.4"
  database_name               = var.db_name
  master_username             = var.db_master_username
  master_password             = var.db_master_password
  db_subnet_group_name        = aws_db_subnet_group.main.name
  vpc_security_group_ids      = [aws_security_group.rds.id]
  storage_encrypted           = true
  kms_key_id                  = var.kms_key_arn
  backup_retention_period     = var.backup_retention_period
  preferred_backup_window     = var.preferred_backup_window
  preferred_maintenance_window = var.preferred_maintenance_window
  deletion_protection         = var.deletion_protection
  skip_final_snapshot         = true
  apply_immediately           = true
  copy_tags_to_snapshot       = true

  serverlessv2_scaling_configuration {
    min_capacity = var.min_capacity
    max_capacity = var.max_capacity
  }

  tags = { Name = "${var.name_prefix}-aurora-cluster" }
}

resource "aws_rds_cluster_instance" "main" {
  count              = 2
  identifier         = "${var.name_prefix}-aurora-${count.index}"
  cluster_identifier = aws_rds_cluster.main.id
  instance_class     = "db.serverless"
  engine             = aws_rds_cluster.main.engine
  engine_version     = aws_rds_cluster.main.engine_version

  performance_insights_enabled    = true
  performance_insights_kms_key_id = var.kms_key_arn

  tags = { Name = "${var.name_prefix}-aurora-instance-${count.index}" }
}
