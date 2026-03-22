resource "aws_ecr_repository" "osp_inspiration_ecr_repository" {
  name                 = "ops-inspiration-console"
  image_tag_mutability = "IMMUTABLE_WITH_EXCLUSION"

  force_delete = true

  image_tag_mutability_exclusion_filter {
    filter_type = "WILDCARD"
    filter      = "latest"
  }

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = {
    Name = "ops-inspriration-ecr-repository"
  }
}

resource "aws_ecr_lifecycle_policy" "osp_inspiration_ecr_lifecycle_policy" {
  repository = aws_ecr_repository.osp_inspiration_ecr_repository.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 10 images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
