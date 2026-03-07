resource "aws_s3_bucket" "health_logs" {
  bucket        = "a4l-health-check-logs-123456"
  force_destroy = true
  tags = {
    Name = "health-check-logs"
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
