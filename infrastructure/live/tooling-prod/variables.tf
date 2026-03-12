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

variable "gitlab_db_user" {
  description = "Database username for GitLab."
  default     = "a4lgitlabuser"
  type        = string
}

variable "gitlab_db_password" {
  description = "Database password for GitLab."
  default     = "4n1m4l54L1f3"
  type        = string
  sensitive   = true
}

variable "gitlab_db_name" {
  description = "Database name for GitLab."
  default     = "gitlabhq_production"
  type        = string
}
