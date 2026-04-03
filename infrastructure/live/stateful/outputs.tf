output "gitlab_db_endpoint" {
  value = module.gitlab_database.db_endpoint
}

output "gitlab_cache_endpoint" {
  value = module.gitlab_cache.cache_endpoint
}

output "gitlab_db_security_group_id" {
  value = module.gitlab_database.db_security_group_id
}

output "gitlab_cache_security_group_id" {
  value = module.gitlab_cache.cache_security_group_id
}
