
output "cache_endpoint" {
  value = aws_elasticache_replication_group.cache.primary_endpoint_address
}

output "cache_security_group_id" {
  value = aws_security_group.cache.id
}
