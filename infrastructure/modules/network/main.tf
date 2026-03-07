locals {
  private_subnet_tags_per_az = {
    for az in var.available_azs_names :
    az => {
      Name = "gitlab-private-${az}-10.16.0.0"
    }
  }
  public_subnet_tags_per_az = {
    for az in var.available_azs_names :
    az => {
      Name = "gitlab-public-${az}-10.16.0.0"
    }
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.6.0"

  name                   = "gitlab-vpc"
  cidr                   = "10.16.0.0/16"
  azs                    = var.available_azs_names
  enable_nat_gateway     = true
  one_nat_gateway_per_az = true
  single_nat_gateway     = false
  elasticache_subnets    = ["10.16.64.0/20", "10.16.128.0/20", "10.16.192.0/20"]
  public_subnets         = ["10.16.48.0/20", "10.16.112.0/20", "10.16.176.0/20"]
  private_subnets        = ["10.16.32.0/20", "10.16.96.0/20", "10.16.160.0/20"]
  database_subnets       = ["10.16.16.0/20", "10.16.80.0/20", "10.16.144.0/20"]
  enable_dns_hostnames   = true
  enable_dns_support     = true
  tags = {
    Name = "gitlab-vpc"
  }
  #   enable_ipv6 = true
  #   public_subnet_assign_ipv6_address_on_creation   = true
  #   database_subnet_assign_ipv6_address_on_creation = true
  #   private_subnet_assign_ipv6_address_on_creation  = true
  map_public_ip_on_launch = true

  igw_tags = {
    Name = "gitlab-igw"
  }
  public_route_table_tags = {
    Name = "gitlab-vpc-rt-public"
  }
  private_route_table_tags = {
    Name = "gitlab-vpc-rt-private"
  }
  private_subnet_tags_per_az = local.private_subnet_tags_per_az
  public_subnet_tags_per_az  = local.public_subnet_tags_per_az
  nat_gateway_tags = {
    Name = "gitlab-nat-gw"
  }
  database_subnet_group_tags = {
    Name = "gitlab-database-subnet-group"
  }

  #   database_subnet_ipv6_prefixes = [1, 5, 9]
  #   private_subnet_ipv6_prefixes  = [2, 6, 10]
  #   public_subnet_ipv6_prefixes   = [3, 7, 11]
}
