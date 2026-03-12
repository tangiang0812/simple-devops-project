variable "public_subnets" {
  description = "List of public subnet IDs to launch the EC2 instance in."
  type        = list(string)
}

variable "private_subnets" {
  description = "List of private subnet IDs to launch the EC2 instance in."
  type        = list(string)
}

variable "bastion_host_sec_group" {
  description = "Security group ID for the bastion host."
  type        = string
}

variable "gitlab_rails_sec_group" {
  description = "Security group ID for the GitLab Rails instance."
  type        = string
}

variable "bastion_instance_profile_id" {
  description = "IAM instance profile ID for the bastion host."
  type        = string
}

variable "gitlab_rails_instance_profile_arn" {
  description = "IAM instance profile ARN for the GitLab Rails instance."
  type        = string
}

variable "gitlab_alb_http_target_group_arn" {
  description = "ARN of the GitLab ALB HTTP target group."
  type        = string
}
