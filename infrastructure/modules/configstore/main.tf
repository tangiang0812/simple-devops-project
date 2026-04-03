resource "aws_ssm_parameter" "this" {
  count     = length(var.parameters)
  name      = var.parameters[count.index].name
  type      = var.parameters[count.index].type
  data_type = var.parameters[count.index].data_type
  value     = var.parameters[count.index].value
  tier      = var.parameters[count.index].tier
  overwrite = var.parameters[count.index].overwrite
}
