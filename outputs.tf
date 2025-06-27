output "client_security_group_id" {
  description = "Security group id for the elasticache clients."
  value       = aws_security_group.client.id
}

output "cache_host" {
  description = "Hostname of the cache endpoint (traditional cluster primary endpoint or serverless endpoint)."
  value = local.is_serverless ? (
    length(aws_elasticache_serverless_cache.elasticache) > 0 ? aws_elasticache_serverless_cache.elasticache[0].endpoint[0].address : null
    ) : (
    length(aws_elasticache_replication_group.elasticache) > 0 ? aws_elasticache_replication_group.elasticache[0].primary_endpoint_address : null
  )
}

output "cache_port" {
  description = "Port of the cache endpoint."
  value = local.is_serverless ? (
    length(aws_elasticache_serverless_cache.elasticache) > 0 ? aws_elasticache_serverless_cache.elasticache[0].endpoint[0].port : null
    ) : (
    local.cache_port
  )
}

output "security_group_id" {
  description = "Security group id for the elasticache."
  value       = aws_security_group.elasticache.id
}

output "cache_type" {
  description = "Type of cache created (redis, valkey, redis-serverless, valkey-serverless)."
  value       = var.cache_type
}

output "cache_engine" {
  description = "Cache engine (redis or valkey)."
  value       = local.cache_engine
}

output "is_serverless" {
  description = "Whether the cache is serverless."
  value       = local.is_serverless
}

# Traditional cluster specific outputs
output "redis_host" {
  description = "Hostname of the redis/valkey host in the replication group (traditional clusters only)."
  value       = !local.is_serverless && length(aws_elasticache_replication_group.elasticache) > 0 ? aws_elasticache_replication_group.elasticache[0].primary_endpoint_address : null
}

output "replication_group_id" {
  description = "ID of the ElastiCache replication group (traditional clusters only)."
  value       = !local.is_serverless && length(aws_elasticache_replication_group.elasticache) > 0 ? aws_elasticache_replication_group.elasticache[0].replication_group_id : null
}

# Serverless specific outputs
output "serverless_cache_name" {
  description = "Name of the serverless cache (serverless caches only)."
  value       = local.is_serverless && length(aws_elasticache_serverless_cache.elasticache) > 0 ? aws_elasticache_serverless_cache.elasticache[0].name : null
}

output "serverless_cache_arn" {
  description = "ARN of the serverless cache (serverless caches only)."
  value       = local.is_serverless && length(aws_elasticache_serverless_cache.elasticache) > 0 ? aws_elasticache_serverless_cache.elasticache[0].arn : null
}
