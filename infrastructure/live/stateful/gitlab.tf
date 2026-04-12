module "gitlab_database" {
  source = "../../modules/database"

  name                 = "gitlab"
  vpc_id               = local.network.vpc_id
  db_subnet_group_name = local.network.database_subnet_group_name
  db_name              = var.gitlab_db_name
  username             = var.gitlab_db_user
  password             = var.gitlab_db_password

  tags = {
    Environment = "production"
    Project     = "gitlab"
  }

}

module "gitlab_cache" {
  source = "../../modules/cache"

  name                          = "gitlab"
  elasticache_subnet_group_name = local.network.elasticache_subnet_group_name
  vpc_id                        = local.network.vpc_id

  tags = {
    Environment = "production"
    Project     = "gitlab"
  }
}

module "gitlab_s3" {
  source = "../../modules/storage/s3"
  for_each = toset([
    "artifacts",
    "mr-diffs",
    "lfs",
    "uploads",
    "packages",
    "dependency-proxy",
    "terraform-state",
    "ci-secure-files",
    "pages"
  ])

  name          = "gitlab-${each.key}"
  force_destroy = true
  suffix        = "gnaig"

  tags = {
    Environment = "production"
    Project     = "gitlab"
  }
}

module "gitlab_s3_health_logs" {
  source = "../../modules/storage/s3"

  name                           = "gitlab-alb-health-logs"
  force_destroy                  = true
  attach_elb_log_delivery_policy = true
  suffix                         = "gnaig"

  tags = {
    Environment = "production"
    Project     = "gitlab"
  }
}

module "gitlab-ansible-ssm-bucket" {
  source = "../../modules/storage/s3"

  name                           = "ansible-ssm-bucket"
  force_destroy                  = true
  attach_elb_log_delivery_policy = true
  suffix                         = "gnaig"

  tags = {
    Environment = "production"
    Project     = "gitlab"
  }
}
