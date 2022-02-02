locals {
  replication_group_id = substr(
    "${var.base_name}-ec-cluster",
    0,
    min(20, length("${var.base_name}-ec-cluster")),
  )
  # To enable, number_cache_clusters greater than 1
  automatic_failover_enabled = var.redis_cluster_config.node_count > 1
  # To enable, automatic_failover_enabled must also be enabled
  multi_az_enabled = var.multi_az_enabled == true && local.automatic_failover_enabled == true
}
