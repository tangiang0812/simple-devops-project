module "gitlab_cert" {
  source          = "../../modules/certificates"
  domain_name     = "gnaig.click"
  route53_zone_id = module.alias_dns_record.zone_id

  tags = {
    Environment = "production"
    Project     = "gitlab"
  }
}

module "alias_dns_record" {
  source               = "../../modules/dns"
  domain_name          = "gnaig.click"
  subdomain_name       = "gitlab"
  vpc_id               = local.network.vpc_id
  route53_zone_id      = data.aws_route53_zone.route53_zone.zone_id
  alias_dns_name       = module.gitlab_nlb.lb_dns_name
  alias_hosted_zone_id = module.gitlab_nlb.lb_hosted_zone_id

  tags = {
    Environment = "production"
    Project     = "gitlab"
  }
}

module "gitlab_nlb" {
  source          = "../../modules/loadbalancer"
  name            = "gitlab-nlb"
  lb_type         = "network"
  internal        = false
  subnet_ids      = local.network.public_subnets
  vpc_id          = local.network.vpc_id
  ip_address_type = "ipv4"
  target_groups = {
    int_abl = {
      name              = "gitlab-http-alb"
      target_type       = "alb"
      protocol          = "TCP"
      port              = 443
      create_attachment = true
      target_id         = module.gitlab_alb.lb_id
      health_check = {
        protocol = "HTTPS"
        port     = 443
        path     = "/-/health"
        matcher  = "200-399"
        interval = 30
      }
    }

    int_ssh = {
      name        = "gitlab-ssh"
      target_type = "instance"
      protocol    = "TCP"
      port        = 22
      health_check = {
        protocol = "TCP"
        port     = "22"
        interval = 30
      }
    }
  }

  listeners = {
    ext_https = {
      port     = 443
      protocol = "TCP"
      default_action = {
        type             = "forward"
        target_group_key = "int_abl"
      }
    }

    ext_ssh = {
      port     = 22
      protocol = "TCP"
      default_action = {
        type             = "forward"
        target_group_key = "int_ssh"
      }
    }
  }


  tags = {
    Environment = "production"
    Project     = "gitlab"
  }
}

module "gitlab_alb" {
  source          = "../../modules/loadbalancer"
  name            = "gitlab-alb"
  lb_type         = "application"
  subnet_ids      = local.network.private_subnets
  vpc_id          = local.network.vpc_id
  ip_address_type = "ipv4"
  target_groups = {
    int_instance = {
      name        = "gitlab-instance"
      target_type = "instance"
      port        = 80
      protocol    = "HTTP"
      health_check = {
        protocol = "HTTP"
        port     = 80
        path     = "/-/health"
        matcher  = "200-399"
        interval = 30
      }
    }
  }

  listeners = {
    int_https = {
      port            = 443
      protocol        = "HTTPS"
      certificate_arn = module.gitlab_cert.cert_arn
      default_action = {
        type             = "forward"
        target_group_key = "int_instance"
      }
    }

  }

  tags = {
    Environment = "production"
    Project     = "gitlab"
  }
}

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

module "gitlab_rails_role" {
  source = "../../modules/iam"
  name   = "gitlab-rails"
  managed_policy_arns = [
    aws_iam_policy.gitlab_rails_s3_access_policy.arn,
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
  ]
  create_instance_profile = true

  tags = {
    Environment = "production"
    Project     = "gitlab"
  }
}

# module "bastion_role" {
#   source = "../../modules/iam"
#   name   = "bastion"

#   managed_policy_arns     = ["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"]
#   create_instance_profile = true

#   tags = {
#     Environment = "production"
#     Project     = "gitlab"
#   }
# }

module "gitlab_runner_role" {
  source = "../../modules/iam"
  name   = "gitlab-runner"

  managed_policy_arns = [
    aws_iam_policy.gitlab_rails_s3_access_policy.arn,
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
  ]
  create_instance_profile = true

  tags = {
    Environment = "production"
    Project     = "gitlab"
  }
}

# module "bastion" {
#   source               = "../../modules/compute"
#   name                 = "gitlab-bastion"
#   vpc_id               = local.network.vpc_id
#   ami_id               = data.aws_ami.amazon_linux.id
#   subnets              = local.network.private_subnets
#   instance_profile_arn = module.bastion_role.instance_profile_arn
#   # user_data            = filebase64("${path.module}/templates/user_data_bastion.sh")

#   tags = {
#     Environment = "production"
#     Project     = "gitlab"
#   }
# }

module "gitlab_rails" {
  source               = "../../modules/compute"
  name                 = "gitlab-rails"
  vpc_id               = local.network.vpc_id
  ami_id               = data.aws_ami.gitlab_rails_ami.id
  subnets              = local.network.private_subnets
  instance_profile_arn = module.gitlab_rails_role.instance_profile_arn
  lb_target_group_arn  = module.gitlab_alb.target_group_arns["int_instance"]
  user_data            = filebase64("${path.module}/templates/user-data-gitlab-rails.sh")

  tags = {
    Environment = "production"
    Project     = "gitlab"
  }
}

module "gitlab_runner" {
  source               = "../../modules/compute"
  name                 = "gitlab-runner"
  vpc_id               = local.network.vpc_id
  ami_id               = data.aws_ami.gitlab_rails_ami.id
  subnets              = local.network.private_subnets
  instance_profile_arn = module.gitlab_runner_role.instance_profile_arn
  user_data            = filebase64("${path.module}/templates/user-data-gitlab-runner.sh")

  tags = {
    Environment = "production"
    Project     = "gitlab"
  }
}

module "ssm_parameters" {
  source = "../../modules/configstore"

  parameters = [
    {
      name      = "/gitlab/domain_name"
      type      = "String"
      data_type = "text"
      value     = var.domain_name
      tier      = "Standard"
      overwrite = true
    },
    {
      name      = "/gitlab/postgresql/db_endpoint"
      type      = "String"
      data_type = "text"
      value     = local.stateful.gitlab_db_endpoint
      tier      = "Standard"
      overwrite = true
    },
    {
      name      = "/gitlab/postgresql/db_name"
      type      = "String"
      data_type = "text"
      value     = var.gitlab_db_name
      tier      = "Standard"
      overwrite = true
    },
    {
      name      = "/gitlab/postgresql/db_user"
      type      = "String"
      data_type = "text"
      value     = var.gitlab_db_user
      tier      = "Standard"
      overwrite = true
    },
    {
      name      = "/gitlab/postgresql/db_password"
      type      = "SecureString"
      data_type = "text"
      value     = var.gitlab_db_password
      tier      = "Standard"
      overwrite = true
    },
    {
      name      = "/gitlab/redis/cache_endpoint"
      type      = "String"
      data_type = "text"
      value     = local.stateful.gitlab_cache_endpoint
      tier      = "Standard"
      overwrite = true
    },
    {
      name      = "/gitlab/rails/rails_password"
      type      = "SecureString"
      data_type = "text"
      value     = var.gitlab_root_password
      tier      = "Standard"
      overwrite = true
    }
  ]
}

resource "aws_vpc_security_group_ingress_rule" "ingress_gitlab_nlb_ssh_from_any" {
  security_group_id = module.gitlab_nlb.lb_security_group_id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "ingress_gitlab_nlb_https_from_any" {
  security_group_id = module.gitlab_nlb.lb_security_group_id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

# resource "aws_vpc_security_group_egress_rule" "egress_gitlab_nlb_ssh_to_bastion_host" {
#   security_group_id            = module.gitlab_nlb.lb_security_group_id
#   referenced_security_group_id = module.bastion.security_group_id
#   # cidr_ipv4         = "0.0.0.0/0"
#   from_port   = 22
#   ip_protocol = "tcp"
#   to_port     = 22
# }

resource "aws_vpc_security_group_egress_rule" "egress_gitlab_nlb_https_to_gitlab_alb" {
  security_group_id            = module.gitlab_nlb.lb_security_group_id
  referenced_security_group_id = module.gitlab_alb.lb_security_group_id
  # cidr_ipv4         = "0.0.0.0/0"
  from_port   = 443
  ip_protocol = "tcp"
  to_port     = 443
}

resource "aws_vpc_security_group_ingress_rule" "ingress_gitlab_alb_https_from_gitlab_nlb" {
  security_group_id            = module.gitlab_alb.lb_security_group_id
  referenced_security_group_id = module.gitlab_nlb.lb_security_group_id
  from_port                    = 443
  ip_protocol                  = "tcp"
  to_port                      = 443
}

resource "aws_vpc_security_group_egress_rule" "egress_gitlab_alb_http_to_gitlab_rails" {
  security_group_id            = module.gitlab_alb.lb_security_group_id
  referenced_security_group_id = module.gitlab_rails.security_group_id
  from_port                    = 80
  ip_protocol                  = "tcp"
  to_port                      = 80
}

# resource "aws_vpc_security_group_ingress_rule" "ingress_gitlab_rails_ssh_from_gitlab_bastion_host" {
#   security_group_id            = module.gitlab_rails.security_group_id
#   referenced_security_group_id = module.bastion.security_group_id
#   from_port                    = 22
#   ip_protocol                  = "tcp"
#   to_port                      = 22
# }

resource "aws_vpc_security_group_ingress_rule" "ingress_gitlab_rails_http_from_gitlab_alb" {
  security_group_id            = module.gitlab_rails.security_group_id
  referenced_security_group_id = module.gitlab_alb.lb_security_group_id
  from_port                    = 80
  ip_protocol                  = "tcp"
  to_port                      = 80
}

resource "aws_vpc_security_group_egress_rule" "egress_gitlab_rails_to_gitlab_rds" {
  security_group_id            = module.gitlab_rails.security_group_id
  referenced_security_group_id = local.stateful.gitlab_db_security_group_id
  from_port                    = 5432
  ip_protocol                  = "tcp"
  to_port                      = 5432
}

resource "aws_vpc_security_group_egress_rule" "egress_gitlab_rails_to_gitlab_redis" {
  security_group_id            = module.gitlab_rails.security_group_id
  referenced_security_group_id = local.stateful.gitlab_cache_security_group_id
  from_port                    = 6379
  ip_protocol                  = "tcp"
  to_port                      = 6379
}

resource "aws_vpc_security_group_egress_rule" "egress_gitlab_rails_https_to_any" {
  security_group_id = module.gitlab_rails.security_group_id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

# this is for ssm
resource "aws_vpc_security_group_egress_rule" "egress_gitlab_runner_https_to_any" {
  security_group_id = module.gitlab_runner.security_group_id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}
# this is for apt update 
resource "aws_vpc_security_group_egress_rule" "egress_gitlab_runner_http_to_any" {
  security_group_id = module.gitlab_runner.security_group_id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

# resource "aws_vpc_security_group_ingress_rule" "ingress_bastion_host_ssh_from_gitlab_nlb" {
#   security_group_id            = module.bastion.security_group_id
#   referenced_security_group_id = module.gitlab_nlb.lb_security_group_id
#   from_port                    = 22
#   ip_protocol                  = "tcp"
#   to_port                      = 22
# }

# resource "aws_vpc_security_group_egress_rule" "egress_bastion_host_to_ssm" {
#   security_group_id = module.bastion.security_group_id
#   cidr_ipv4         = "0.0.0.0/0"
#   from_port         = 443
#   ip_protocol       = "tcp"
#   to_port           = 443
# }

# resource "aws_vpc_security_group_egress_rule" "egress_bastion_host_ssh_to_gitlab_rails" {
#   security_group_id            = module.bastion.security_group_id
#   referenced_security_group_id = module.gitlab_rails.security_group_id
#   from_port                    = 22
#   ip_protocol                  = "tcp"
#   to_port                      = 22
# }

resource "aws_vpc_security_group_ingress_rule" "ingress_gitlab_rds_postgres_from_gitlab_rails" {
  security_group_id            = local.stateful.gitlab_db_security_group_id
  referenced_security_group_id = module.gitlab_rails.security_group_id
  from_port                    = 5432
  ip_protocol                  = "tcp"
  to_port                      = 5432
}

resource "aws_vpc_security_group_ingress_rule" "ingress_gitlab_redis_from_gitlab_rails" {
  security_group_id            = local.stateful.gitlab_cache_security_group_id
  referenced_security_group_id = module.gitlab_rails.security_group_id
  from_port                    = 6379
  ip_protocol                  = "tcp"
  to_port                      = 6379
}
