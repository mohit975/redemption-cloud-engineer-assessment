resource "aws_db_subnet_group" "aurora" {
  name       = "${var.name}-aurora"
  subnet_ids = var.subnet_ids

  tags = merge(var.tags, {
    Name = "${var.name}-aurora"
  })
}

resource "aws_rds_cluster" "aurora" {
  cluster_identifier              = "${var.name}-aurora"
  engine                          = "aurora-postgresql"
  engine_version                  = "16.4"
  database_name                   = var.db_name
  master_username                 = var.db_username
  master_password                 = var.db_password
  db_subnet_group_name            = aws_db_subnet_group.aurora.name
  vpc_security_group_ids          = [var.security_group_id]
  storage_encrypted               = true
  kms_key_id                      = var.kms_key_arn
  backup_retention_period         = 7
  preferred_backup_window         = "17:00-19:00"
  skip_final_snapshot             = var.skip_final_snapshot
  copy_tags_to_snapshot           = true
  deletion_protection             = true
  enabled_cloudwatch_logs_exports = ["postgresql"]

  serverlessv2_scaling_configuration {
    min_capacity = 1
    max_capacity = 16
  }

  tags = merge(var.tags, {
    Name = "${var.name}-aurora"
  })
}

resource "aws_rds_cluster_instance" "aurora" {
  count = var.instance_count

  identifier                   = "${var.name}-aurora-${count.index + 1}"
  cluster_identifier           = aws_rds_cluster.aurora.id
  instance_class               = "db.serverless"
  engine                       = aws_rds_cluster.aurora.engine
  engine_version               = aws_rds_cluster.aurora.engine_version
  performance_insights_enabled = true

  tags = merge(var.tags, {
    Name = "${var.name}-aurora-${count.index + 1}"
  })
}

resource "aws_secretsmanager_secret" "database" {
  name       = "${var.name}/database"
  kms_key_id = var.kms_key_arn

  tags = merge(var.tags, {
    Name = "${var.name}-database-secret"
  })
}

resource "aws_secretsmanager_secret_version" "database" {
  secret_id = aws_secretsmanager_secret.database.id
  secret_string = jsonencode({
    host     = aws_rds_cluster.aurora.endpoint
    dbname   = var.db_name
    username = var.db_username
    password = var.db_password
    port     = 5432
  })
}
