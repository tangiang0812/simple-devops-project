resource "aws_iam_policy" "gitlab_rails_s3_access_policy" {
  name        = "gitlab-rails-s3-access-policy"
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
