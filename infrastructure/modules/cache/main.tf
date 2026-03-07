resource "aws_elasticache_replication_group" "gitlab_redis" {
  replication_group_id = "gitlab-redis"
  description          = "GitLab Redis replication group"

  engine                     = "redis"
  engine_version             = "6.x"
  node_type                  = "cache.t3.micro"
  port                       = 6379
  num_cache_clusters         = 3
  multi_az_enabled           = true
  automatic_failover_enabled = true
  subnet_group_name          = var.elasticache_subnet_group_name
  security_group_ids         = var.security_group_ids

  lifecycle {
    ignore_changes = [num_cache_clusters]
  }

  tags = {
    Name = "gitlab-redis"
  }

}
