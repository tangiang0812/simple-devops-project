output "vpc_id" {
  value = module.network.vpc_id
}

output "public_subnets" {
  value = module.network.public_subnets
}

output "private_subnets" {
  value = module.network.private_subnets
}

output "database_subnet_group_name" {
  value = module.network.database_subnet_group_name
}

output "elasticache_subnet_group_name" {
  value = module.network.elasticache_subnet_group_name
}
