variable "cluster_name" {
  description = "EKS cluster name — used for IRSA trust policies"
  type        = string
}

variable "cluster_oidc_provider_arn" {
  description = "OIDC provider ARN of the EKS cluster — used for IRSA IAM roles"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources created by this module"
  type        = map(string)
  default     = {}
}

# ── Metrics Server ────────────────────────────────────────────────────────────
variable "enable_metrics_server" {
  description = "Install Metrics Server (required for HPA)"
  type        = bool
  default     = true
}

variable "metrics_server_chart_version" {
  description = "Helm chart version for Metrics Server"
  type        = string
  default     = "3.12.1"
}
