output "client_security_group_id" {
  description = "Security group id for the elasticache clients."
  value       = aws_security_group.client.id
}

output "redis_host" {
  description = "Hostname of the redis host in the replication group."
  value       = aws_elasticache_replication_group.elasticache.primary_endpoint_address
}
