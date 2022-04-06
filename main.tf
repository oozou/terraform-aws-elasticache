# AZs from the supplied subnets
data "aws_subnet" "subnets" {
  count = var.redis_cluster_config.node_count
  id    = var.vpc_config.private_subnets[count.index]
}

# Elasticache subnet group
resource "aws_elasticache_subnet_group" "elasticache" {
  name       = "${local.service_name}-ec-subnet-group"
  subnet_ids = var.vpc_config.private_subnets
}

# Replication Group - ElastiCache Redis cluster
resource "aws_elasticache_replication_group" "elasticache" {
  # Group ID can only be max 20 chars
  replication_group_id          = local.replication_group_id
  description = "AWS ElastiCache cluster with Redis engine and Multi-AZ."

  # Redis configuration
  node_type      = var.redis_cluster_config.instance_type
  port           = var.redis_cluster_config.port
  engine         = "redis"
  engine_version = var.redis_cluster_config.engine_version

  # Subnets, AZs & Security
  subnet_group_name  = aws_elasticache_subnet_group.elasticache.name
  availability_zones = data.aws_subnet.subnets.*.availability_zone
  security_group_ids = [aws_security_group.elasticache.id]

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
    Name = "${local.service_name}-ec-cluster"
  }, local.tags)
}
