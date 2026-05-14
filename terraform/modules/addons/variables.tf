variable "cluster_name" {
  description = "EKS cluster name — used for IRSA trust policies"
  type        = string
}

variable "cluster_oidc_provider_arn" {
  description = "OIDC provider ARN of the EKS cluster — used for IRSA IAM roles"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID — passed to AWS Load Balancer Controller"
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

# ── AWS Load Balancer Controller ──────────────────────────────────────────────
variable "enable_aws_load_balancer_controller" {
  description = "Install AWS Load Balancer Controller (required for ALB/NLB Ingress)"
  type        = bool
  default     = true
}

variable "aws_load_balancer_controller_chart_version" {
  description = "Helm chart version for AWS Load Balancer Controller"
  type        = string
  default     = "1.8.1"
}

# ── AWS EBS CSI Driver IRSA ──────────────────────────────────────────────────
variable "enable_aws_ebs_csi_driver" {
  description = "Create IRSA role for the EBS CSI driver managed add-on"
  type        = bool
  default     = true
}

# ── Cert-Manager ─────────────────────────────────────────────────────────────
variable "enable_cert_manager" {
  description = "Install cert-manager for ACME HTTP-01 certificate issuance"
  type        = bool
  default     = true
}

variable "cert_manager_chart_version" {
  description = "Helm chart version for cert-manager"
  type        = string
  default     = "v1.11.0"
}
