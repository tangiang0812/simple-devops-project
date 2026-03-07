variable "elasticache_subnet_group_name" {
  description = "The name of the Elasticache subnet group to use for the Redis cluster"
  type        = string
}

variable "security_group_ids" {
  description = "A list of security group IDs to associate with the Redis cluster"
  type        = list(string)
}
