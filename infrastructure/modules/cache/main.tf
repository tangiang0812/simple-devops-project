resource "aws_security_group" "cache" {
  name        = "${var.name}-cache-sg"
  description = "Security group for ${var.name} Redis cluster"
  vpc_id      = var.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "cache_from_app" {
  count                        = var.ingress_source_security_group_id != null ? 1 : 0
  security_group_id            = aws_security_group.cache.id
  referenced_security_group_id = var.ingress_source_security_group_id
  from_port                    = 6379
  to_port                      = 6379
  ip_protocol                  = "tcp"
}


resource "aws_elasticache_replication_group" "cache" {
  replication_group_id = var.replication_group_id
  description          = var.description

  engine                     = "redis"
  engine_version             = "7.0"
  node_type                  = var.node_type
  port                       = 6379
  num_cache_clusters         = var.number_cache_clusters
  multi_az_enabled           = var.multi_az_enabled
  automatic_failover_enabled = var.automatic_failover_enabled
  subnet_group_name          = var.elasticache_subnet_group_name
  security_group_ids         = [aws_security_group.cache.id]
  transit_encryption_enabled = true
  apply_immediately          = true
  transit_encryption_mode    = "preferred"

  lifecycle {
    ignore_changes = [num_cache_clusters]
  }

  tags = merge({
    Name = "${var.name}-cache"
  }, var.tags)
}
