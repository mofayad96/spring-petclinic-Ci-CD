variable "cluster_name" {
  type        = string
  description = "EKS Cluster Name"
}

variable "region" {
  type        = string
  description = "AWS Region"
  default     = "eu-central-1"
}

variable "repo_url" {
  type        = string
  description = "Git Repository URL"
}

variable "image_repository" {
  type        = string
  description = "ECR Repository URI"
}
