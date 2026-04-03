variable "name" {
  description = "Base bucket names to create."
  type        = string
}

variable "attach_elb_log_delivery_policy" {
  description = "Whether to attach the ELB log delivery policy to the health logs bucket."
  type        = bool
  default     = true
}

variable "suffix" {
  description = "Suffix to append to each bucket name."
  type        = string
}

variable "force_destroy" {
  description = "Whether to force destroy the S3 buckets when deleting the module."
  type        = bool
  default     = true
}

variable "tags" {
  description = "A map of tags to assign to the S3 buckets."
  type        = map(string)
  default     = {}
}
