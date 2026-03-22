output "name_servers" {
  value = module.dns.name_servers
}

output "gitlab_nlb_dns_name" {
  value = module.loadbalancer.nlb_dns_name
}

output "gitlab_alb_dns_name" {
  value = module.loadbalancer.alb_dns_name
}

output "gitlab_db_endpoint" {
  value = module.database.db_endpoint
}

output "gitlab_redis_endpoint" {
  value = module.cache.gitlab_redis_endpoint
}

output "route53_zone_id" {
  value = module.dns.zone_id
}

output "ecr_repository_url" {
  value = module.ecr.repository_url
}
