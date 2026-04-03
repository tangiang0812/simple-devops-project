module "appcluster_ecr" {
  source               = "../../modules/ecr"
  name                 = "ops-inspiration-console"
  force_delete         = true
  image_tag_mutability = "IMMUTABLE_WITH_EXCLUSION"

  tags = {
    Environment = "production"
    Project     = "app"
  }
}
