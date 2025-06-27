# AZs from the supplied subnets (only for traditional clusters)
data "aws_subnet" "subnets" {
  count = !local.is_serverless && var.redis_cluster_config != null ? var.redis_cluster_config.node_count : 1
  id    = var.vpc_config.private_subnets[count.index]
}

# Elasticache subnet group (only for traditional clusters)
resource "aws_elasticache_subnet_group" "elasticache" {
  count      = !local.is_serverless ? 1 : 0
  name       = "${local.service_name}-ec-sngroup"
  subnet_ids = var.vpc_config.private_subnets

  tags = merge({
    Name = "${local.service_name}-ec-sngroup"
  }, local.tags)
}

# Traditional Replication Group - ElastiCache Redis/Valkey cluster
resource "aws_elasticache_replication_group" "elasticache" {
  count = !local.is_serverless ? 1 : 0

  # Group ID can only be max 20 chars
  replication_group_id = "${local.service_name}-ec"
  description          = "AWS ElastiCache cluster with ${local.cache_engine} engine and Multi-AZ."

  # Engine configuration
  node_type      = var.redis_cluster_config.instance_type
  port           = var.redis_cluster_config.port
  engine         = local.cache_engine
  engine_version = var.redis_cluster_config.engine_version

  # Subnets, AZs & Security
  subnet_group_name           = aws_elasticache_subnet_group.elasticache[0].name
  preferred_cache_cluster_azs = data.aws_subnet.subnets.*.availability_zone
  security_group_ids          = [aws_security_group.elasticache.id]

  # HA
  num_cache_clusters         = var.redis_cluster_config.node_count
  automatic_failover_enabled = local.automatic_failover_enabled
  multi_az_enabled           = local.multi_az_enabled
  auto_minor_version_upgrade = true

  # Backup and Maintenance
  snapshot_window          = var.snapshot_config.snapshot_window
  snapshot_retention_limit = var.snapshot_config.snapshot_retention_limit
  maintenance_window       = var.maintenance_window

  # Encryption
  auth_token                 = var.auth_token
  at_rest_encryption_enabled = true
  transit_encryption_enabled = true

  tags = merge({
    Name = "${local.service_name}-ec"
  }, local.tags)
}

# Serverless Cache - ElastiCache Redis/Valkey serverless
resource "aws_elasticache_serverless_cache" "elasticache" {
  count = local.is_serverless ? 1 : 0

  name        = "${local.service_name}-serverless"
  description = var.serverless_config.description != null ? var.serverless_config.description : "AWS ElastiCache serverless ${local.cache_engine} cache"
  engine      = local.cache_engine

  # Cache usage limits
  dynamic "cache_usage_limits" {
    for_each = var.serverless_config.cache_usage_limits != null ? [var.serverless_config.cache_usage_limits] : []
    content {
      dynamic "data_storage" {
        for_each = cache_usage_limits.value.data_storage != null ? [cache_usage_limits.value.data_storage] : []
        content {
          maximum = data_storage.value.maximum
          unit    = data_storage.value.unit
        }
      }
      dynamic "ecpu_per_second" {
        for_each = cache_usage_limits.value.ecpu_per_second != null ? [cache_usage_limits.value.ecpu_per_second] : []
        content {
          maximum = ecpu_per_second.value.maximum
        }
      }
    }
  }

  # Networking
  subnet_ids         = var.vpc_config.private_subnets
  security_group_ids = length(var.serverless_security_group_ids) > 0 ? var.serverless_security_group_ids : [aws_security_group.elasticache.id]

  # Backup and snapshots
  daily_snapshot_time      = var.serverless_config.daily_snapshot_time
  snapshot_retention_limit = var.serverless_config.snapshot_retention_limit
  snapshot_arns_to_restore = var.serverless_config.snapshot_arns_to_restore

  # Encryption and auth
  kms_key_id    = var.serverless_config.kms_key_id
  user_group_id = var.serverless_config.user_group_id

  tags = merge({
    Name = "${local.service_name}-serverless"
  }, local.tags)
}
