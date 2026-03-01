variable "aws_region" {
  description = "AWS region to deploy EKS"
  default     = "eu-west-3" # Paris region, France
}

variable "cluster_name" {
  description = "EKS cluster name"
  default     = "eks-dev-cluster"
}
