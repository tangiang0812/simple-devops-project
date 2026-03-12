variable "efs_dns_name" {
  description = "The DNS name of the EFS file system to store in SSM Parameter Store."
  type        = string
  default     = ""
}

variable "gitlab_db_endpoint" {
  description = "The endpoint of the RDS database to store in SSM Parameter Store."
  type        = string
}

variable "gitlab_db_user" {
  description = "The database username for GitLab to store in SSM Parameter Store."
  type        = string
}

variable "gitlab_db_password" {
  description = "The database password for GitLab to store in SSM Parameter Store."
  type        = string
  sensitive   = true
}

variable "gitlab_db_name" {
  description = "The database name for GitLab to store in SSM Parameter Store."
  type        = string
}

variable "domain_name" {
  description = "The domain name for the application to store in SSM Parameter Store."
  type        = string
}

variable "gitlab_redis_endpoint" {
  description = "The hostname or endpoint of the Redis instance for GitLab to store in SSM Parameter Store."
  type        = string
}
