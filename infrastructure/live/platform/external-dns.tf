resource "aws_iam_policy" "allow_externalDNS_updates" {
  name        = "Allow_External_DNS_updates"
  path        = "/"
  description = "Allow S3 object and bucket operations for gitlab-* buckets"

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

resource "aws_iam_role" "external_dns" {
  name = "external-dns-irsa-role"

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
}

resource "aws_iam_role_policy_attachment" "external_dns" {
  role       = aws_iam_role.external_dns.name
  policy_arn = resource.aws_iam_policy.allow_externalDNS_updates.arn
}

resource "local_file" "external_dns_serviceaccount_yaml" {
  content = templatefile("${path.module}/templates/external-dns-serviceaccount.yaml.tpl", {
    ROLE_ARN = aws_iam_role.external_dns.arn
  })
  filename = "${path.module}/../../../manifest/external-dns/external-dns-serviceaccount.yaml"
}
