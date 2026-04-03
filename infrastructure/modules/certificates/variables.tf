variable "domain_name" {
  description = "The domain name for the ACM certificate."
  type        = string
}

variable "route53_zone_id" {
  description = "The ID of the Route 53 hosted zone."
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the resources."
  type        = map(string)
  default     = {}
}
