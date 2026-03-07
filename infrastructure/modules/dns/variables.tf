variable "nlb_dns_name" {
  description = "The domain name for the ACM certificate."
  type        = string
}

variable "nlb_hosted_zone_id" {
  description = "The hosted zone ID of GitLab NLB."
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC to associate with the Route 53 hosted zone."
  type        = string
}

variable "domain_name" {
  description = "The domain name for the ACM certificate."
  type        = string
}

# variable "gitlab_alb_cert_domain_validation_options" {
#   description = "Domain validation options for the ACM certificate."
#   type = list(object({
#     domain_name           = string
#     resource_record_name  = string
#     resource_record_value = string
#     resource_record_type  = string
#   }))
# }
