variable "db_subnet_group_name" {
  description = "The name of the DB subnet group to use for the RDS instance"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC to deploy the RDS instance in"
  type        = string
}

variable "name" {
  description = "The name of the RDS instance"
  type        = string
  default     = "gitlab"
}

variable "identifier" {
  type    = string
  default = "gitlab-db-ha"
}

variable "instance_class" {
  description = "The instance class to use for the RDS instance"
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "The allocated storage in GB for the RDS instance"
  type        = number
  default     = 5
}

variable "engine" {
  description = "The database engine to use for the RDS instance"
  type        = string
  default     = "postgres"
}

variable "engine_version" {
  description = "The version of the database engine to use for the RDS instance"
  type        = string
  default     = "14"
}

variable "parameter_group_family" {
  description = "The family of the DB parameter group to use for the RDS instance"
  type        = string
  default     = "postgres14"
}

variable "db_name" {
  description = "The name of the database to create in the RDS instance"
  type        = string
}

variable "username" {
  description = "The username for the database master user"
  type        = string

}

variable "password" {
  description = "The password for the database master user"
  type        = string
  sensitive   = true
}

variable "skip_final_snapshot" {
  description = "Whether to skip the final snapshot when deleting the RDS instance"
  type        = bool
  default     = true
}

variable "multi_az" {
  description = "Whether "
  type        = bool
  default     = true
}

variable "ingress_source_security_group_id" {
  description = "The ID of the security group to allow ingress from for the RDS instance"
  type        = string
  default     = null
}

variable "tags" {
  description = "A map of tags to apply to the RDS instance"
  type        = map(string)
  default     = {}
}
