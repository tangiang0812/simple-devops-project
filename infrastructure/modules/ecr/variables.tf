variable "name" {
  description = "The name of the ECR repository"
  type        = string
  default     = "ops-inspiration-console"
}

variable "image_tag_mutability" {
  description = "The tag mutability setting for the ECR repository"
  type        = string
  default     = "IMMUTABLE"
}

variable "force_delete" {
  description = "Whether to force delete the ECR repository"
  type        = bool
  default     = false
}

variable "lifecycle_max_images" {
  description = "The maximum number of images to retain in the ECR repository"
  type        = number
  default     = 10
}

variable "tags" {
  description = "A map of tags to assign to the ECR repository"
  type        = map(string)
  default     = {}
}
