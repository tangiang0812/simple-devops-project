# output "external_dns_serviceaccount_yaml" {
#   value = templatefile("${path.module}/templates/external-dns-serviceaccount.yaml.tpl", {
#     ROLE_ARN = aws_iam_role.external_dns.arn
#   })
# }
