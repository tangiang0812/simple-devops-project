variable "name" {
  description = "The name of the IAM role."
  type        = string
}

# variable "assume_role_policy" {
#   description = "The trust relationship policy that grants an entity permission to assume the role."
#   type        = string
# }

variable "managed_policy_arns" {
  description = "A list of ARNs of managed policies to attach to the role."
  type        = list(string)
  default     = []
}

variable "create_instance_profile" {
  type    = bool
  default = false
}

variable "tags" {
  description = "A map of tags to assign to the role."
  type        = map(string)
  default     = {}
}
