output "ssm_parameters" {
  value = [
    for param in aws_ssm_parameter.this : {
      name  = param.name
      value = param.value
    }
  ]
}
