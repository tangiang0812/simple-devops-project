variable "vpc_id" {
  description = "The ID of the VPC to associate with the Route 53 hosted zone."
  type        = string
}

variable "domain_name" {
  description = "The domain name for the ACM certificate."
  type        = string
}

# variable "subdomain_name" {
#   description = "The sub domain name for the ACM certificate."
#   type        = string
# }

variable "route53_zone_id" {
  description = "The ID of the existing Route 53 hosted zone to use."
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the Route 53 hosted zone."
  type        = map(string)
  default     = {}
}

variable "alias_hosted_zone_id" {
  description = "The hosted zone ID of the load balancer to create an alias record for."
  type        = string
}

variable "alias_dns_name" {
  description = "The DNS name of the load balancer to create an alias record for."
  type        = string
}
