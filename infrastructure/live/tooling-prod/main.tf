module "network" {
  source = "../../modules/network"
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
  gitlab_rails_instance_profile_arn = module.iam.gitlab_rails_instance_profile_arn
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
  gitlab_rails_password = var.gitlab_root_password
}

module "ecr" {
  source = "../../modules/ecr"
}

module "eks_al2023" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name                                     = "ops-inspiration-console"
  kubernetes_version                       = "1.33"
  endpoint_public_access                   = true
  enable_cluster_creator_admin_permissions = true

  # EKS Addons
  addons = {
    coredns = {}
    eks-pod-identity-agent = {
      before_compute = true
    }
    kube-proxy = {}
    vpc-cni = {
      before_compute = true
    }
  }

  vpc_id     = module.network.vpc_id
  subnet_ids = module.network.private_subnets

  eks_managed_node_groups = {
    example = {
      # Starting on 1.30, AL2023 is the default AMI type for EKS managed node groups
      instance_types = ["m7i-flex.large"]
      ami_type       = "AL2023_x86_64_STANDARD"

      min_size = 2
      max_size = 5
      # This value is ignored after the initial creation
      # https://github.com/bryantbiggs/eks-desired-size-hack
      desired_size = 2

      # This is not required - demonstrates how to pass additional configuration to nodeadm
      # Ref https://awslabs.github.io/amazon-eks-ami/nodeadm/doc/api/
      # cloudinit_pre_nodeadm = [
      #   {
      #     content_type = "application/node.eks.aws"
      #     content      = <<-EOT
      #       ---
      #       apiVersion: node.eks.aws/v1alpha1
      #       kind: NodeConfig
      #       spec:
      #         kubelet:
      #           config:
      #             shutdownGracePeriod: 30s
      #     EOT
      #   }
      # ]
    }
  }

  tags = {
    Name = "ops-inspiration-console"
  }
}
