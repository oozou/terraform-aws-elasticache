locals {
  environment  = var.environment
  service_name = "${var.prefix}-${var.environment}-${var.name}"

  tags = merge(
    {
      "Environment" = local.environment,
      "Terraform"   = "true"
    },
    var.tags
  )

  # Cache type logic
  is_serverless = contains(["redis-serverless", "valkey-serverless"], var.cache_type)
  is_valkey     = contains(["valkey", "valkey-serverless"], var.cache_type)

  # Engine determination
  cache_engine = local.is_valkey ? "valkey" : "redis"

  # Traditional cluster logic (only for non-serverless)
  automatic_failover_enabled = !local.is_serverless && var.redis_cluster_config != null ? var.redis_cluster_config.node_count > 1 : false
  multi_az_enabled           = !local.is_serverless && var.multi_az_enabled == true && local.automatic_failover_enabled == true

  # Validation logic
  cluster_config_required    = !local.is_serverless && var.redis_cluster_config == null
  serverless_config_required = local.is_serverless && var.serverless_config == null

  # Port determination
  cache_port = local.is_serverless ? 6379 : (var.redis_cluster_config != null ? var.redis_cluster_config.port : 6379)

  /* -------------------------------------------------------------------------- */
  /*                                    Alarms                                  */
  /* -------------------------------------------------------------------------- */
  comparison_operators = {
    ">=" = "GreaterThanOrEqualToThreshold",
    ">"  = "GreaterThanThreshold",
    "<"  = "LessThanThreshold",
    "<=" = "LessThanOrEqualToThreshold",
  }
}
