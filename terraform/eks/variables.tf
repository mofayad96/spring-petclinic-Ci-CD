variable "cluster_name" {
  type    = string
  default = "springpetclinic-eks"
}
variable "cluster_role_arn" {
  type        = string
  description = "IAM role ARN for the EKS cluster"
}
variable "node_role_arn" {
  type        = string
  description = "IAM role ARN for the EKS node group"
}
variable "private_subnet_ids" {
  type        = list(string)
  description = "Private subnets where EKS nodes will run"
}

variable "node_instance_types" {
  type    = list(string)
  default = ["t3.small"]
}

variable "desired_size" {
  type    = number
  default = 3
}

variable "max_size" {
  type    = number
  default = 4
}

variable "min_size" {
  type    = number
  default = 1
}

variable "node_group_name" {
  type    = string
  default = "springpetclinic-nodes"
}

variable "log_retention_in_days" {
  type    = number
  default = 7
}