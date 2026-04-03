module "network" {
  source = "../../modules/network"

  name = var.vpc_name
  cidr = var.vpc_cidr


  elasticache_subnets = var.elasticache_subnets
  public_subnets      = var.public_subnets
  private_subnets     = var.private_subnets
  database_subnets    = var.database_subnets

  tags = {
    Environment = "production"
  }
}
