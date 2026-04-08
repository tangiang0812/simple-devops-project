module "this" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name                                     = var.cluster_name
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

  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids

  eks_managed_node_groups = {
    default = {
      instance_types = var.instance_types
      ami_type       = "AL2023_x86_64_STANDARD"

      min_size     = var.min_size
      max_size     = var.max_size
      desired_size = var.desired_size
    }
  }

  tags = merge({
    Name = "${var.cluster_name}-cluster"
  }, var.tags)
}
