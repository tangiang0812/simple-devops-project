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
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:PutObjectAcl",
        ]
        Resource = "arn:aws:s3:::gitlab-*/*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:AbortMultipartUpload",
          "s3:ListMultipartUploadParts",
          "s3:ListBucketMultipartUploads",
        ]
        Resource = "arn:aws:s3:::gitlab-*"
      },
    ]
  })
}

resource "aws_iam_role" "gitlab_rails_role" {
  name = "gitlab_rails_role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
  path = "/"

  tags = {
    Name = "gitlab_rails_role"
  }
}

resource "aws_iam_role_policy_attachment" "gitlab_rails_s3_access_attachment" {
  role       = aws_iam_role.gitlab_rails_role.name
  policy_arn = aws_iam_policy.gitlab_rails_s3_access_policy.arn
}

resource "aws_iam_role_policy_attachment" "gitlab_rails_ssm_access" {
  role       = aws_iam_role.gitlab_rails_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMFullAccess"
}

resource "aws_iam_role_policy_attachment" "gitlab_rails_ecr_access" {
  role       = aws_iam_role.gitlab_rails_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

# resource "aws_iam_role_policy_attachment" "gitlab_rails_asg_readonly" {
#   role       = aws_iam_role.gitlab_rails_role.name
#   policy_arn = "arn:aws:iam::aws:policy/AutoScalingReadOnlyAccess"
# }

# resource "aws_iam_role_policy_attachment" "gitlab_rails_ec2_readonly" {
#   role       = aws_iam_role.gitlab_rails_role.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
# }

resource "aws_iam_instance_profile" "gitlab_rails_instance_profile" {
  name = "gitlab_rails_instance_profile"
  role = aws_iam_role.gitlab_rails_role.name
}

resource "aws_iam_role" "bastion_role" {
  name = "bastion_role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
  path = "/"

  tags = {
    Name = ""
  }
}

resource "aws_iam_role_policy_attachment" "AmazonSSMFullAccess" {
  role       = aws_iam_role.bastion_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMFullAccess"
}

resource "aws_iam_instance_profile" "bastion_instance_profile" {
  name = "bastion_instance_profile"
  role = aws_iam_role.bastion_role.name
}


