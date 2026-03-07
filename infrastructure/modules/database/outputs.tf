output "db_endpoint" {
  value = aws_db_instance.gitlab_db_ha.address
}
