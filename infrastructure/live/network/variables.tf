variable "region" {
  type    = string
  default = "us-east-1"
}

variable "vpc_name" {
  type    = string
  default = "gnaig"
}

variable "vpc_cidr" {
  type    = string
  default = "10.16.0.0/16"
}

variable "az_count" {
  type    = number
  default = 2
}

variable "public_subnets" {
  type    = list(string)
  default = ["10.16.48.0/20", "10.16.112.0/20"]
}

variable "private_subnets" {
  type    = list(string)
  default = ["10.16.32.0/20", "10.16.96.0/20"]
}

variable "database_subnets" {
  type    = list(string)
  default = ["10.16.16.0/20", "10.16.80.0/20"]
}

variable "elasticache_subnets" {
  type    = list(string)
  default = ["10.16.64.0/20", "10.16.128.0/20"]
}
