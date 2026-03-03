data "aws_availability_zones" "available" {}

module "network" {
  source              = "../../modules/network"
  available_azs_names = slice(data.aws_availability_zones.available.names, 0, 3)
}
module "iam" {
  source = "../../modules/iam"
}
