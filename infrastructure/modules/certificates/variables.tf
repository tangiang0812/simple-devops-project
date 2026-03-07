variable "domain_name" {
  description = "The domain name for the ACM certificate."
  type        = string
}

variable "nlb_hosted_zone_id" {
  description = "Hosted zone ID of the load balancer."
  type        = string
}

variable "zone_id" {
  description = "The ID of the Route 53 hosted zone."
  type        = string
}
