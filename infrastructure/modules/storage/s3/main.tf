
locals {
  gitlab_buckets = [
    "gitlab-artifacts",
    "gitlab-mr-diffs",
    "gitlab-lfs",
    "gitlab-uploads",
    "gitlab-packages",
    "gitlab-dependency-proxy",
    "gitlab-terraform-state",
    "gitlab-ci-secure-files",
    "gitlab-pages"
  ]
}

resource "aws_s3_bucket" "gitlab" {
  for_each = toset(local.gitlab_buckets)

  bucket        = "${each.value}-fjal"
  force_destroy = true
  tags = {
    Name = each.value
  }
}

resource "aws_s3_bucket" "health_logs" {
  bucket        = "gitlab-alb-health-check-logs-fjal"
  force_destroy = true
  tags = {
    Name = "alb-health-check-logs"
  }
}

data "aws_elb_service_account" "main" {}

resource "aws_s3_bucket_policy" "alb_logs" {
  bucket = aws_s3_bucket.health_logs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = data.aws_elb_service_account.main.arn
        }
        Action = "s3:PutObject"
        Resource = [
          "${aws_s3_bucket.health_logs.arn}/*"
        ]
      }
    ]
  })
}
