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
  subnets               = module.network.public_subnets
  vpc_id                = module.network.vpc_id
  health_logs_bucket_id = module.s3.health_logs_bucket_id
  alb_cert_arn          = module.certificates.gitlab_alb_cert_arn
}

# module "dns" {
#   source             = "../../modules/dns"
#   domain_name        = var.domain_name
#   nlb_dns_name       = module.loadbalancer.nlb_dns_name
#   nlb_hosted_zone_id = module.loadbalancer.nlb_hosted_zone_id
#   vpc_id             = module.network.vpc_id
# }

# module "certificates" {
#   source             = "../../modules/certificates"
#   domain_name        = var.domain_name
#   nlb_hosted_zone_id = module.loadbalancer.nlb_hosted_zone_id
#   zone_id            = module.dns.zone_id
# }
