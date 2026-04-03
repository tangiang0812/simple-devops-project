variable "vpc_id" {
  description = "The ID of the VPC to launch the EC2 instance in."
  type        = string
}

variable "subnets" {
  description = "List of subnet IDs to launch the EC2 instance in."
  type        = list(string)
}

variable "name" {
  description = "The name of the EC2 instance / Auto Scaling Group."
  type        = string
}

variable "instance_profile_id" {
  description = "IAM instance profile ID for intance."
  type        = string
  default     = ""
}

variable "instance_profile_arn" {
  description = "IAM instance profile ARN for the instance."
  type        = string
}

variable "lb_target_group_arn" {
  description = "ARN of the ALB HTTP target group."
  type        = string
  default     = ""
}

variable "ami_id" {
  description = "The ID of the AMI to use for the EC2 instance."
  type        = string
}

variable "user_data" {
  description = "The user data to provide when launching the EC2 instance."
  type        = string
  default     = ""
}

variable "tags" {
  description = "A map of tags to assign to the EC2 instance and related resources."
  type        = map(string)
  default     = {}
}
