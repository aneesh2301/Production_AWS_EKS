variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "eu-west-3"
}

variable "project" {
  description = "Project name used in naming and tagging"
  type        = string
  default     = "eks-production-project"
}

variable "environment" {
  description = "Environment name (dev, stage, prod)"
  type        = string
  default     = "dev"
}

# ── VPC ───────────────────────────────────────────────────────────────────────

variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "azs" {
  description = "Availability zones to deploy into"
  type        = list(string)
}

variable "private_subnets" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
}

variable "public_subnets" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
}

variable "enable_nat_gateway" {
  description = "Create a NAT Gateway for private subnet egress"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Use a single NAT Gateway (cost saving for dev)"
  type        = bool
  default     = true
}

# ── EKS ───────────────────────────────────────────────────────────────────────

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
}

variable "cluster_endpoint_public_access" {
  description = "Enable public access to the cluster API endpoint"
  type        = bool
  default     = true
}

variable "cluster_endpoint_private_access" {
  description = "Enable private access to the cluster API endpoint"
  type        = bool
  default     = false
}

variable "enable_irsa" {
  description = "Enable IAM Roles for Service Accounts (IRSA)"
  type        = bool
  default     = true
}

variable "cluster_enabled_log_types" {
  description = "List of control plane log types to enable"
  type        = list(string)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

variable "cluster_addons" {
  description = "EKS managed addons to install"
  type        = any
  default = {
    coredns    = { most_recent = true }
    kube-proxy = { most_recent = true }
    vpc-cni    = { most_recent = true }
  }
}

variable "node_group" {
  description = "Managed node group configuration"
  type = object({
    name           = string
    instance_types = list(string)
    min_size       = number
    max_size       = number
    desired_size   = number
    capacity_type  = string
  })
}

# ── Add-ons ───────────────────────────────────────────────────────────────────

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

variable "enable_aws_ebs_csi_driver" {
  description = "Enable the EBS CSI driver managed add-on and create its IRSA role"
  type        = bool
  default     = true
}

variable "enable_external_dns" {
  description = "Install ExternalDNS for Route53 record management"
  type        = bool
  default     = true
}

variable "external_dns_chart_version" {
  description = "Helm chart version for ExternalDNS"
  type        = string
  default     = "1.14.5"
}

variable "external_dns_hosted_zone_arns" {
  description = "Route53 hosted zone ARNs that ExternalDNS is allowed to manage"
  type        = list(string)
  default     = ["arn:aws:route53:::hostedzone/*"]
}

variable "external_dns_domain_filters" {
  description = "Optional list of DNS suffixes ExternalDNS should manage"
  type        = list(string)
  default     = []
}

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
