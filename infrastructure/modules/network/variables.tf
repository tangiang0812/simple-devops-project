variable "name" {
  description = "The name of the VPC."
  type        = string
}

variable "cidr" {
  description = "The CIDR block for the VPC."
  type        = string
}

variable "az_count" {
  description = "Number of AZs to use."
  type        = number
  default     = 2
}

variable "public_subnets" {
  description = "A list of CIDR blocks for the public subnets."
  type        = list(string)
}

variable "private_subnets" {
  description = "A list of CIDR blocks for the private subnets."
  type        = list(string)
}

variable "database_subnets" {
  description = "Database subnet CIDRs."
  type        = list(string)
}
variable "elasticache_subnets" {
  description = "ElastiCache subnets CIDRs."
  type        = list(string)
}

variable "enable_nat_gateway" {
  description = "Whether to enable NAT gateways."
  type        = bool
  default     = true
}
variable "one_nat_gateway_per_az" {
  description = "Whether to create one NAT gateway per availability zone. If false, a single NAT gateway will be created in the first availability zone."
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Whether to create a single NAT gateway. If true, a single NAT gateway will be created in the first availability zone. This variable is deprecated in favor of one_nat_gateway_per_az."
  type        = bool
  default     = false

}

variable "map_public_ip_on_launch" {
  description = "Whether to map public IPs on launch for the public subnets. If true, instances launched in the public subnets will receive a public IP address."
  type        = bool
  default     = true
}

variable "tags" {
  description = "A map of tags to assign to the VPC and its sub-resources."
  type        = map(string)
  default     = {}
}
