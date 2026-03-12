output "ssm_parameters" {
  value = [
    aws_ssm_parameter.gitlab_db_endpoint.value,
    aws_ssm_parameter.gitlab_db_name.value,
    aws_ssm_parameter.gitlab_db_user.value,
    aws_ssm_parameter.gitlab_db_password.value,
    aws_ssm_parameter.domain_name.value,
    aws_ssm_parameter.gitlab_redis_endpoint.value,
    # aws_ssm_parameter.efs_dns.value,
  ]
}
