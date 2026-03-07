variable "nlb_sec_group_id" {
  description = "The ID of the security group to associate with the network load balancer."
  type        = string
}
variable "alb_sec_group_id" {
  description = "The ID of the security group to associate with the application load balancer."
  type        = string
}

variable "subnets" {
  description = "List of subnet IDs to associate with the load balancer."
  type        = list(string)
}

variable "vpc_id" {
  description = "The ID of the VPC where the load balancer will be created."
  type        = string
}

variable "health_logs_bucket_id" {
  description = "The name of the S3 bucket for load balancer access logs."
  type        = string
}


variable "alb_cert_arn" {
  description = "The ARN of the ACM certificate for the application load balancer."
  type        = string
}
