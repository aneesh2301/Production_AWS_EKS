# ── General ───────────────────────────────────────────────────────────────────
aws_region  = "eu-west-3"
project     = "eks-production-project"
environment = "dev"

# ── VPC ───────────────────────────────────────────────────────────────────────
vpc_name           = "eks-vpc"
vpc_cidr           = "10.0.0.0/16"
azs                = ["eu-west-3a", "eu-west-3b"]
private_subnets    = ["10.0.1.0/24", "10.0.2.0/24"]
public_subnets     = ["10.0.101.0/24", "10.0.102.0/24"]
enable_nat_gateway = true
single_nat_gateway = true

# ── EKS ───────────────────────────────────────────────────────────────────────
cluster_name                    = "eks-dev-cluster"
cluster_version                 = "1.29"
cluster_endpoint_public_access  = true
cluster_endpoint_private_access = false
enable_irsa                     = true

node_group = {
  name           = "dev-nodes"
  instance_types = ["t3.medium"]
  min_size       = 1
  max_size       = 2
  desired_size   = 2
  capacity_type  = "ON_DEMAND"
}

# ── Add-ons ───────────────────────────────────────────────────────────────────
enable_metrics_server        = true
metrics_server_chart_version = "3.12.1"

# ── AWS Load Balancer Controller ──────────────────────────────────────────────
enable_aws_load_balancer_controller        = true
aws_load_balancer_controller_chart_version = "1.8.1"

# ── AWS EBS CSI Driver ───────────────────────────────────────────────────────
enable_aws_ebs_csi_driver = true

# ── Karpenter ────────────────────────────────────────────────────────────────
enable_karpenter        = true
karpenter_chart_version = "1.6.0"

# ── External DNS ─────────────────────────────────────────────────────────────
enable_external_dns           = true
external_dns_chart_version    = "1.14.5"
external_dns_hosted_zone_arns = ["arn:aws:route53:::hostedzone/*"]
external_dns_domain_filters   = []

# ── Cert-Manager ─────────────────────────────────────────────────────────────
enable_cert_manager        = true
cert_manager_chart_version = "v1.11.0"
