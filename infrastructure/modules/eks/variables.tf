variable "cluster_name" {
  description = "The name of the EKS cluster"
}
variable "cluster_version" {
  default = "1.29"
}
variable "cluster_role_arn" {
  description = "The ARN of the IAM role that provides permissions for the EKS cluster to make API calls to AWS services on your behalf."
}
variable "node_role_arn" {
  description = "The ARN of the IAM role that provides permissions for the EKS worker nodes to make API calls to AWS services on your behalf."
}
variable "subnet_ids" {
  description = "The list of subnet IDs for the EKS cluster"
  type        = list(string)
}
variable "instance_types" {
  description = "The list of instance types for the EKS worker nodes"
  type        = list(string)
  default     = ["t3.medium"]
}
variable "desired_size" {
  description = "The desired number of worker nodes in the EKS node group"
  default     = 2
}
variable "min_size" {
  description = "The minimum number of worker nodes in the EKS node group"
  default     = 1
}
variable "max_size" {
  description = "The maximum number of worker nodes in the EKS node group"
  default     = 2
}
