module "eks_al2023" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name                                     = "ops-inspiration-console"
  kubernetes_version                       = "1.33"
  endpoint_public_access                   = true
  enable_cluster_creator_admin_permissions = true

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

  vpc_id     = local.network.vpc_id
  subnet_ids = local.network.private_subnets

  eks_managed_node_groups = {
    example = {
      instance_types = ["m7i-flex.large"]
      ami_type       = "AL2023_x86_64_STANDARD"

      min_size     = 2
      max_size     = 5
      desired_size = 2
    }
  }

  tags = {
    Name = "ops-inspiration-console"
  }
}

resource "aws_iam_policy" "aws_load_balancer_controller_policy" {
  name        = "Allow_AWS_Load_Balancer_Controller_permissions"
  path        = "/"
  description = "Allow permissions for AWS Load Balancer Controller"

  policy = file("${path.module}/templates/aws-load-balancer-controller-iam-policy.json")
}

resource "aws_iam_role" "aws_load_balancer_controller" {
  name = "aws-load-balancer-controller-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${module.eks_al2023.oidc_provider}"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${module.eks_al2023.oidc_provider}:sub" = "system:serviceaccount:kube-system:aws-load-balancer-controller"
            "${module.eks_al2023.oidc_provider}:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "aws_load_balancer_controller" {
  role       = aws_iam_role.aws_load_balancer_controller.name
  policy_arn = aws_iam_policy.aws_load_balancer_controller_policy.arn
}

resource "local_file" "aws_load_balancer_controller_serviceaccount_yaml" {
  content = templatefile("${path.module}/templates/aws-load-balancer-controller-serviceaccount.yaml.tpl", {
    ROLE_ARN = aws_iam_role.aws_load_balancer_controller.arn
  })
  filename = "${path.module}/../../../manifest/aws-load-balancer-controller/aws-load-balancer-controller-serviceaccount.yaml"
}
