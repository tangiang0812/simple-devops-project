variable "region" {
  default     = "us-east-1"
  description = "AWS region"
}

variable "domain_name" {
  description = "The domain name for the ACM certificate."
  default     = "gnaig.click"
  type        = string
}

variable "route53_zone_id" {
  description = "The ID of the existing Route 53 hosted zone to use."
  default     = "Z0771552XNTYMRHKW4VW"
  type        = string
}
