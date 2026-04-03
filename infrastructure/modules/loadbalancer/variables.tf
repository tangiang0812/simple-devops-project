variable "subnet_ids" {
  description = "List of subnet IDs to associate with the application load balancer."
  type        = list(string)
}

variable "vpc_id" {
  description = "The ID of the VPC where the load balancer will be created."
  type        = string
}

variable "name" {
  description = "The name of the load balancer."
  type        = string
}

variable "lb_type" {
  description = "The type of load balancer to create (application or network)."
  type        = string
  validation {
    condition     = contains(["application", "network"], var.lb_type)
    error_message = "lb_type must be application or network."
  }
}

variable "internal" {
  description = "Whether to create an internal load balancer (true) or an internet-facing load balancer (false)."
  type        = bool
  default     = true
}

variable "ip_address_type" {
  description = "The type of IP address to use for the load balancer (ipv4 or dualstack)."
  type        = string
  validation {
    condition     = contains(["ipv4", "dualstack"], var.ip_address_type)
    error_message = "ip_address_type must be ipv4 or dualstack."
  }
}

variable "ingress_rules" {
  description = "A list of ingress rules to apply to the load balancer security group."
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = []
}

variable "target_groups" {
  description = "A list of target groups to create for the load balancer."
  type = map(object({
    name              = string
    port              = number
    protocol          = string
    target_type       = string
    target_id         = optional(string)
    create_attachment = optional(bool, false)
    health_check = optional(object({
      enabled           = optional(bool)
      healthy_threshold = optional(number)
      interval          = optional(number)
      matcher           = optional(string)
      path              = optional(string)
      port              = optional(string)
      protocol          = optional(string)
    }))
  }))
  default = {}
  validation {
    condition = alltrue([
      for k, v in var.target_groups :
      (
        (coalesce(v.create_attachment, true) == false)
        ||
        (v.target_id != null)
      )

    ])

    error_message = "target_id must be provided when create_attachment is true."
  }

  # validation {
  #   condition = alltrue([
  #     for k, v in var.target_groups :
  #     (
  #       # If protocol is TCP/UDP → matcher MUST NOT be set
  #       !contains(["TCP", "UDP"], v.health_check.protocol)
  #       ||
  #       (
  #         v.health_check == null ||
  #         v.health_check.matcher == null
  #       )
  #     )
  #   ])

  #   error_message = "matcher cannot be set for TCP/UDP target groups."
  # }
}

variable "listeners" {
  description = "A list of listeners to create for the load balancer."
  type = map(object({
    port            = number
    protocol        = string
    certificate_arn = optional(string)
    ssl_policy      = optional(string)

    default_action = object({
      type             = string
      target_group_key = string
    })
  }))
  default = {}
}


variable "access_logs" {
  description = "The name of the S3 bucket for load balancer access logs."
  type = object({
    buck   = string
    prefix = optional(string)
  })
  default = null
}

variable "alb_cert_arn" {
  description = "The ARN of the ACM certificate for the application load balancer."
  type        = string
  default     = null
}

variable "tags" {
  description = "A map of tags to assign to the load balancer and related resources."
  type        = map(string)
  default     = {}
}
