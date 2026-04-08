module "application_cluster" {
  source = "../../modules/eks"

  cluster_name = "ops-inspiration-console"
  subnet_ids   = local.network.private_subnets
  vpc_id       = local.network.vpc_id

  tags = {
    Name = "ops-inspiration-console"
  }
}

resource "aws_iam_policy" "aws_load_balancer_controller_policy" {
  name        = "aws-load-balancer-controller-policy"
  path        = "/"
  description = "Allow permissions for AWS Load Balancer Controller"

  policy = file("${path.module}/templates/aws-load-balancer-controller-iam-policy.json")
}

module "aws_load_balancer_controller" {
  source                  = "../../modules/iam"
  name                    = "aws-load-balancer-controller"
  create_instance_profile = false

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${module.application_cluster.oidc_provider}"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${module.application_cluster.oidc_provider}:sub" = "system:serviceaccount:kube-system:aws-load-balancer-controller"
            "${module.application_cluster.oidc_provider}:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })

  managed_policy_arns = [
    aws_iam_policy.aws_load_balancer_controller_policy.arn,
  ]

  tags = {
    Environment = "production"
    Project     = "aws-load-balancer-controller"
  }
}

resource "local_file" "aws_load_balancer_controller_serviceaccount_yaml" {
  content = templatefile("${path.module}/templates/aws-load-balancer-controller-serviceaccount.yaml.tpl", {
    ROLE_ARN = module.aws_load_balancer_controller.role_arn
  })
  filename = "${path.module}/../../../manifest/aws-load-balancer-controller/aws-load-balancer-controller-serviceaccount.yaml"
}

# No need to use this as we can just let AWS Load Balancer Controller discover the correct certificate to use based on the Ingress annotations. 
#This is because we are using a single certificate for all our Ingress resources, so there will be no ambiguity for AWS Load Balancer Controller to resolve.
# resource "local_file" "app_ingress_yaml" {
#   content = templatefile("${path.module}/templates/ingress-app.yaml.tpl", {
#     CERTIFICATE_ARN = module.gitlab_cert.cert_arn
#   })
#   filename = "${path.module}/../../../manifest/app/ingress.yaml"
# }

# resource "local_file" "argocd_ingress_yaml" {
#   content = templatefile("${path.module}/templates/ingress-two-ingress-blocks.yaml.tpl", {
#     CERTIFICATE_ARN = module.gitlab_cert.cert_arn
#   })
#   filename = "${path.module}/../../../manifest/argocd/ingress.yaml"
# }
