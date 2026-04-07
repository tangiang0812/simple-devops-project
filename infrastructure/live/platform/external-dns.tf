resource "aws_iam_policy" "allow_external_dns_updates_policy" {
  name        = "allow-external-dns-updates-policy"
  path        = "/"
  description = "Allow External-DNS to updates Route53 records"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "route53:ChangeResourceRecordSets",
        ]
        Resource = "arn:aws:route53:::hostedzone/*"
      },
      {
        Effect = "Allow"
        Action = [
          "route53:ListHostedZones",
          "route53:ListResourceRecordSets",
          "route53:ListTagsForResource"
        ]
        Resource = "*"
      },
    ]
  })
}

module "external_dns" {
  source                  = "../../modules/iam"
  name                    = "external-dns"
  create_instance_profile = false

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${module.eks_al2023.oidc_provider}"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${module.eks_al2023.oidc_provider}:sub" = "system:serviceaccount:external-dns:external-dns"
            "${module.eks_al2023.oidc_provider}:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })

  managed_policy_arns = [
    aws_iam_policy.allow_external_dns_updates_policy.arn,
  ]

  tags = {
    Environment = "production"
    Project     = "external-dns"
  }
}

resource "local_file" "external_dns_serviceaccount_yaml" {
  content = templatefile("${path.module}/templates/external-dns-serviceaccount.yaml.tpl", {
    ROLE_ARN = module.external_dns.role_arn
  })
  filename = "${path.module}/../../../manifest/external-dns/external-dns-serviceaccount.yaml"
}
