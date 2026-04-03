variable "region" {
  default     = "us-east-1"
  description = "AWS region"
}

variable "domain_name" {
  description = "The domain name for the ACM certificate."
  type        = string
}

variable "route53_zone_id" {
  description = "The ID of the existing Route 53 hosted zone to use."
  type        = string
}

variable "gitlab_db_user" {
  description = "Database username for GitLab."
  type        = string
}

variable "gitlab_db_password" {
  description = "Database password for GitLab."
  type        = string
  sensitive   = true
}

variable "gitlab_db_name" {
  description = "Database name for GitLab."
  type        = string
}

variable "gitlab_root_password" {
  description = "Password for the GitLab Rails application."
  type        = string
  sensitive   = true
}
