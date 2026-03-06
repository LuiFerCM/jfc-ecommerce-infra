resource "random_password" "db" {
  length  = 24
  special = true
  override_special = "!#$%^&*()-_=+"
}

resource "aws_secretsmanager_secret" "db" {
  name                    = "${var.name_prefix}/database"
  kms_key_id              = var.kms_key_arn
  recovery_window_in_days = 7
  description             = "Database credentials for ${var.name_prefix}"
}

resource "aws_secretsmanager_secret_version" "db" {
  secret_id = aws_secretsmanager_secret.db.id
  secret_string = jsonencode({
    username = var.db_username
    password = random_password.db.result
    dbname   = var.db_name
    engine   = "postgres"
  })
}
