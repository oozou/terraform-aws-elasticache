# Redis Traditional Cluster Outputs
output "redis_traditional_cache_host" {
  description = "Redis traditional cluster endpoint"
  value       = module.redis_traditional.cache_host
}

output "redis_traditional_cache_port" {
  description = "Redis traditional cluster port"
  value       = module.redis_traditional.cache_port
}

output "redis_traditional_security_group_id" {
  description = "Redis traditional cluster security group ID"
  value       = module.redis_traditional.security_group_id
}

output "redis_traditional_client_security_group_id" {
  description = "Redis traditional cluster client security group ID"
  value       = module.redis_traditional.client_security_group_id
}

output "redis_traditional_replication_group_id" {
  description = "Redis traditional cluster replication group ID"
  value       = module.redis_traditional.replication_group_id
}

output "redis_traditional_cache_type" {
  description = "Redis traditional cluster cache type"
  value       = module.redis_traditional.cache_type
}

output "redis_traditional_cache_engine" {
  description = "Redis traditional cluster cache engine"
  value       = module.redis_traditional.cache_engine
}

output "redis_traditional_is_serverless" {
  description = "Redis traditional cluster is serverless"
  value       = module.redis_traditional.is_serverless
}

# Valkey Traditional Cluster Outputs
output "valkey_traditional_cache_host" {
  description = "Valkey traditional cluster endpoint"
  value       = module.valkey_traditional.cache_host
}

output "valkey_traditional_cache_port" {
  description = "Valkey traditional cluster port"
  value       = module.valkey_traditional.cache_port
}

output "valkey_traditional_security_group_id" {
  description = "Valkey traditional cluster security group ID"
  value       = module.valkey_traditional.security_group_id
}

output "valkey_traditional_client_security_group_id" {
  description = "Valkey traditional cluster client security group ID"
  value       = module.valkey_traditional.client_security_group_id
}

output "valkey_traditional_replication_group_id" {
  description = "Valkey traditional cluster replication group ID"
  value       = module.valkey_traditional.replication_group_id
}

output "valkey_traditional_cache_type" {
  description = "Valkey traditional cluster cache type"
  value       = module.valkey_traditional.cache_type
}

output "valkey_traditional_cache_engine" {
  description = "Valkey traditional cluster cache engine"
  value       = module.valkey_traditional.cache_engine
}

output "valkey_traditional_is_serverless" {
  description = "Valkey traditional cluster is serverless"
  value       = module.valkey_traditional.is_serverless
}

# Redis Serverless Outputs
output "redis_serverless_cache_host" {
  description = "Redis serverless cache endpoint"
  value       = module.redis_serverless.cache_host
}

output "redis_serverless_cache_port" {
  description = "Redis serverless cache port"
  value       = module.redis_serverless.cache_port
}

output "redis_serverless_security_group_id" {
  description = "Redis serverless cache security group ID"
  value       = module.redis_serverless.security_group_id
}

output "redis_serverless_client_security_group_id" {
  description = "Redis serverless cache client security group ID"
  value       = module.redis_serverless.client_security_group_id
}

output "redis_serverless_cache_name" {
  description = "Redis serverless cache name"
  value       = module.redis_serverless.serverless_cache_name
}

output "redis_serverless_cache_arn" {
  description = "Redis serverless cache ARN"
  value       = module.redis_serverless.serverless_cache_arn
}

output "redis_serverless_cache_type" {
  description = "Redis serverless cache type"
  value       = module.redis_serverless.cache_type
}

output "redis_serverless_cache_engine" {
  description = "Redis serverless cache engine"
  value       = module.redis_serverless.cache_engine
}

output "redis_serverless_is_serverless" {
  description = "Redis serverless cache is serverless"
  value       = module.redis_serverless.is_serverless
}

# Valkey Serverless Outputs
output "valkey_serverless_cache_host" {
  description = "Valkey serverless cache endpoint"
  value       = module.valkey_serverless.cache_host
}

output "valkey_serverless_cache_port" {
  description = "Valkey serverless cache port"
  value       = module.valkey_serverless.cache_port
}

output "valkey_serverless_security_group_id" {
  description = "Valkey serverless cache security group ID"
  value       = module.valkey_serverless.security_group_id
}

output "valkey_serverless_client_security_group_id" {
  description = "Valkey serverless cache client security group ID"
  value       = module.valkey_serverless.client_security_group_id
}

output "valkey_serverless_cache_name" {
  description = "Valkey serverless cache name"
  value       = module.valkey_serverless.serverless_cache_name
}

output "valkey_serverless_cache_arn" {
  description = "Valkey serverless cache ARN"
  value       = module.valkey_serverless.serverless_cache_arn
}

output "valkey_serverless_cache_type" {
  description = "Valkey serverless cache type"
  value       = module.valkey_serverless.cache_type
}

output "valkey_serverless_cache_engine" {
  description = "Valkey serverless cache engine"
  value       = module.valkey_serverless.cache_engine
}

output "valkey_serverless_is_serverless" {
  description = "Valkey serverless cache is serverless"
  value       = module.valkey_serverless.is_serverless
}

# VPC Outputs for testing
output "vpc_id" {
  description = "VPC ID used for testing"
  value       = module.vpc.vpc_id
}

output "private_subnet_ids" {
  description = "Private subnet IDs used for testing"
  value       = module.vpc.database_subnet_ids
}
