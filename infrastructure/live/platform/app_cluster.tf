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
    ops_inspiration_console = {
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
