variable "parameters" {
  description = "The parameters to store in the config store."
  type = list(object({
    name      = string
    type      = string
    data_type = string
    value     = string
    tier      = optional(string, "Standard")
    overwrite = optional(bool, true)
  }))
  default = []
}
