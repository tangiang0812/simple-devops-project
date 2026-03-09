
output "gitlab_redis_endpoint" {
  value = aws_elasticache_replication_group.gitlab_redis.primary_endpoint_address
}
