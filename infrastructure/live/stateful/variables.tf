variable "region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "us-east-1"
}

variable "gitlab_db_name" {
  description = "The name of the GitLab database"
  type        = string
}

variable "gitlab_db_user" {
  description = "The username for the GitLab database"
  type        = string
}

variable "gitlab_db_password" {
  description = "The password for the GitLab database"
  type        = string
  sensitive   = true
}
