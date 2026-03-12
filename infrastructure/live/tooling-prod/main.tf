data "aws_availability_zones" "available" {}

module "network" {
  source              = "../../modules/network"
  available_azs_names = slice(data.aws_availability_zones.available.names, 0, 3)
}

module "iam" {
  source = "../../modules/iam"
}

module "s3" {
  source = "../../modules/storage/s3"
}

module "security" {
  source = "../../modules/security"
  vpc_id = module.network.vpc_id
}

module "loadbalancer" {
  source                = "../../modules/loadbalancer"
  nlb_sec_group_id      = module.security.gitlab_nlb_sec_group.id
  alb_sec_group_id      = module.security.gitlab_alb_sec_group.id
  public_subnets        = module.network.public_subnets
  private_subnets       = module.network.private_subnets
  vpc_id                = module.network.vpc_id
  health_logs_bucket_id = module.s3.health_logs_bucket_id
  alb_cert_arn          = module.certificates.gitlab_alb_cert_arn
}

module "dns" {
  source             = "../../modules/dns"
  domain_name        = var.domain_name
  route53_zone_id    = var.route53_zone_id
  nlb_dns_name       = module.loadbalancer.nlb_dns_name
  nlb_hosted_zone_id = module.loadbalancer.nlb_hosted_zone_id
  vpc_id             = module.network.vpc_id
}

module "certificates" {
  source             = "../../modules/certificates"
  domain_name        = var.domain_name
  nlb_hosted_zone_id = module.loadbalancer.nlb_hosted_zone_id
  zone_id            = module.dns.zone_id
}

module "database" {
  source                 = "../../modules/database"
  db_subnet_group_name   = module.network.database_subnet_group_name
  vpc_security_group_ids = [module.security.gitlab_database_sec_group.id]
}

module "cache" {
  source                        = "../../modules/cache"
  elasticache_subnet_group_name = module.network.elasticache_subnet_group_name
  security_group_ids            = [module.security.gitlab_redis_sec_group.id]
}

module "compute" {
  source                            = "../../modules/compute"
  bastion_host_sec_group            = module.security.bastion_host_sec_group.id
  gitlab_rails_sec_group            = module.security.gitlab_rails_sec_group.id
  private_subnets                   = module.network.private_subnets
  public_subnets                    = module.network.public_subnets
  bastion_instance_profile_id       = module.iam.bastion_instance_profile_id
  bastion_instance_profile_arn      = module.iam.bastion_instance_profile_arn
  gitlab_alb_http_target_group_arn  = module.loadbalancer.gitlab_alb_http_target_group_arn
  gitlab_nlb_ssh_target_group_arn   = module.loadbalancer.gitlab_nlb_ssh_target_group_arn
  gitlab_rails_instance_profile_arn = module.iam.bastion_instance_profile_arn
  depends_on                        = [module.configstore]
}

module "configstore" {
  source                = "../../modules/configstore"
  gitlab_db_user        = var.gitlab_db_user
  gitlab_db_password    = var.gitlab_db_password
  gitlab_db_name        = var.gitlab_db_name
  domain_name           = var.domain_name
  gitlab_db_endpoint    = module.database.db_endpoint
  gitlab_redis_endpoint = module.cache.gitlab_redis_endpoint
}
