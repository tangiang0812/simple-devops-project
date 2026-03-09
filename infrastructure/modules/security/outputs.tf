output "gitlab_nlb_sec_group" {
  value = aws_security_group.gitlab_nlb_sec_group
}

output "gitlab_alb_sec_group" {
  value = aws_security_group.gitlab_alb_sec_group
}

output "gitlab_rails_sec_group" {
  value = aws_security_group.gitlab_rails_sec_group
}

output "gitlab_database_sec_group" {
  value = aws_security_group.gitlab_rds_sec_group
}

output "gitlab_redis_sec_group" {
  value = aws_security_group.gitlab_redis_sec_group
}

output "bastion_host_sec_group" {
  value = aws_security_group.bastion_host_sec_group
}
