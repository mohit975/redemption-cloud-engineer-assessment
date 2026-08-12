resource "aws_elasticache_subnet_group" "redis" {
  name       = "${var.name}-redis"
  subnet_ids = var.subnet_ids

  tags = merge(var.tags, {
    Name = "${var.name}-redis"
  })
}

resource "aws_elasticache_replication_group" "redis" {
  replication_group_id       = replace("${var.name}-redis", "_", "-")
  description                = "Redis cache for the Redemption platform"
  engine                     = "redis"
  engine_version             = "7.1"
  node_type                  = var.redis_node_type
  port                       = 6379
  parameter_group_name       = "default.redis7"
  subnet_group_name          = aws_elasticache_subnet_group.redis.name
  security_group_ids         = [var.security_group_id]
  automatic_failover_enabled = true
  multi_az_enabled           = true
  num_cache_clusters         = var.num_cache_clusters
  at_rest_encryption_enabled = true
  transit_encryption_enabled = true
  kms_key_id                 = var.kms_key_arn
  snapshot_retention_limit   = 7
  apply_immediately          = true

  tags = merge(var.tags, {
    Name = "${var.name}-redis"
  })
}
