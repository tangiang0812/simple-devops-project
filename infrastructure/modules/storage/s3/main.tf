resource "aws_s3_bucket" "bucket" {
  bucket        = var.suffix == "" ? var.name : "${var.name}-${var.suffix}"
  force_destroy = var.force_destroy
  tags = merge({
    Name = "${var.name}-s3"
  }, var.tags)
}

# resource "aws_s3_bucket" "health_logs" {
#   bucket        = "gitlab-alb-health-check-logs-fjal"
#   force_destroy = true
#   tags = {
#     Name = "alb-health-check-logs"
#   }
# }

data "aws_elb_service_account" "main" {}

resource "aws_s3_bucket_policy" "alb_logs" {
  count  = var.attach_elb_log_delivery_policy ? 1 : 0
  bucket = aws_s3_bucket.bucket.id

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
          "${aws_s3_bucket.bucket.arn}/*"
        ]
      }
    ]
  })
}
