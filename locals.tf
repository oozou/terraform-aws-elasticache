locals {
  environment          = var.environment
  replication_group_id = "${var.prefix}-${var.environment}-${var.name}-redis"

  tags = merge(
    {
      "Environment" = local.environment,
      "Terraform"   = "true"
    },
    var.tags
  )
  # To enable, number_cache_clusters greater than 1
  automatic_failover_enabled = var.redis_cluster_config.node_count > 1
  # To enable, automatic_failover_enabled must also be enabled
  multi_az_enabled = var.multi_az_enabled == true && local.automatic_failover_enabled == true
}
