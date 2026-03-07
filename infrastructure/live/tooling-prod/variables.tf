variable "region" {
  default     = "us-east-1"
  description = "AWS region"
}

variable "domain_name" {
  description = "The domain name for the ACM certificate."
  default     = "gnaig.click"
  type        = string
}
