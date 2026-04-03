data "aws_availability_zones" "available" {}

locals { available_azs_names = slice(data.aws_availability_zones.available.names, 0, var.az_count) }

locals {
  private_subnet_tags_per_az = {
    for az in local.available_azs_names :
    az => {
      Name = "${var.name}-private-${az}"
    }
  }
  public_subnet_tags_per_az = {
    for az in local.available_azs_names :
    az => {
      Name = "${var.name}-public-${az}"
    }
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.6.0"

  name                    = var.name
  cidr                    = var.cidr
  azs                     = local.available_azs_names
  enable_nat_gateway      = var.enable_nat_gateway
  one_nat_gateway_per_az  = var.one_nat_gateway_per_az
  single_nat_gateway      = var.single_nat_gateway
  map_public_ip_on_launch = var.map_public_ip_on_launch
  enable_dns_hostnames    = true
  enable_dns_support      = true

  elasticache_subnets = var.elasticache_subnets
  public_subnets      = var.public_subnets
  private_subnets     = var.private_subnets
  database_subnets    = var.database_subnets

  # elasticache_subnets = ["10.16.64.0/20", "10.16.128.0/20", "10.16.192.0/20"]
  # public_subnets      = ["10.16.48.0/20", "10.16.112.0/20", "10.16.176.0/20"]
  # private_subnets     = ["10.16.32.0/20", "10.16.96.0/20", "10.16.160.0/20"]
  # database_subnets    = ["10.16.16.0/20", "10.16.80.0/20", "10.16.144.0/20"]


  tags = merge(var.tags, {
    Name = "${var.name}-vpc"
  })
  #   enable_ipv6 = true
  #   public_subnet_assign_ipv6_address_on_creation   = true
  #   database_subnet_assign_ipv6_address_on_creation = true
  #   private_subnet_assign_ipv6_address_on_creation  = true

  igw_tags = {
    Name = "${var.name}-igw"
  }
  public_route_table_tags = {
    Name = "${var.name}-vpc-rt-public"
  }
  private_route_table_tags = {
    Name = "${var.name}-vpc-rt-private"
  }
  private_subnet_tags_per_az = local.private_subnet_tags_per_az
  public_subnet_tags_per_az  = local.public_subnet_tags_per_az
  nat_gateway_tags = {
    Name = "${var.name}-nat-gw"
  }
  database_subnet_group_tags = {
    Name = "${var.name}-database-subnet-group"
  }

  #   database_subnet_ipv6_prefixes = [1, 5, 9]
  #   private_subnet_ipv6_prefixes  = [2, 6, 10]
  #   public_subnet_ipv6_prefixes   = [3, 7, 11]
}
