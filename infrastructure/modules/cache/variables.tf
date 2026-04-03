variable "elasticache_subnet_group_name" {
  description = "The name of the Elasticache subnet group to use for the Redis cluster"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC to deploy the Redis cluster in"
  type        = string
}

variable "name" {
  description = "The name of the Redis cluster"
  type        = string
  default     = "gitlab-cache"
}

variable "replication_group_id" {
  description = "The replication group ID for the Redis cluster"
  type        = string
  default     = "gitlab-cache-ha"
}

variable "description" {
  description = "A description for the Redis cluster"
  type        = string
  default     = "Redis cluster for GitLab caching"
}

variable "engine_version" {
  description = "The version of the Redis engine to use for the cluster"
  type        = string
  default     = "7.0"
}

variable "node_type" {
  description = "The node type to use for the Redis cluster"
  type        = string
  default     = "cache.t3.micro"
}

variable "number_cache_clusters" {
  description = "The number of cache clusters to create in the Redis cluster"
  type        = number
  default     = 2
}

variable "multi_az_enabled" {
  description = "Whether to enable Multi-AZ for the Redis cluster"
  type        = bool
  default     = true
}

variable "automatic_failover_enabled" {
  description = "Whether to enable automatic failover for the Redis cluster"
  type        = bool
  default     = true
}

variable "ingress_source_security_group_id" {
  description = "The ID of the security group that allows ingress to the Redis cluster"
  type        = string
  default     = null
}

variable "tags" {
  description = "A map of tags to apply to the Redis cluster"
  type        = map(string)
  default     = {}
}
