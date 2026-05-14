locals {
  common_tags = {
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "terraform"
  }

  cluster_addons = merge(
    var.cluster_addons,
    var.enable_aws_ebs_csi_driver ? {
      aws-ebs-csi-driver = {
        most_recent              = true
        service_account_role_arn = module.addons.aws_ebs_role_arn
      }
    } : {}
  )
}

data "aws_caller_identity" "current" {}

module "vpc" {
  source = "../../modules/vpc"

  name               = var.vpc_name
  cidr               = var.vpc_cidr
  azs                = var.azs
  private_subnets    = var.private_subnets
  public_subnets     = var.public_subnets
  enable_nat_gateway = var.enable_nat_gateway
  single_nat_gateway = var.single_nat_gateway
  tags               = local.common_tags
}

module "eks" {
  source = "../../modules/eks"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  # Networking — wired from VPC module outputs
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  cluster_endpoint_public_access  = var.cluster_endpoint_public_access
  cluster_endpoint_private_access = var.cluster_endpoint_private_access

  enable_irsa               = var.enable_irsa
  cluster_enabled_log_types = var.cluster_enabled_log_types
  cluster_addons            = local.cluster_addons
  node_group                = var.node_group

  admin_principal_arn = data.aws_caller_identity.current.arn

  tags = local.common_tags
}

# ── Platform Add-ons ──────────────────────────────────────────────────────────
# Requires the EKS cluster to exist first.
# On first apply run: terraform apply -target=module.vpc -target=module.eks
# Then run:           terraform apply

module "addons" {
  source = "../../modules/addons"

  cluster_name              = var.cluster_name
  cluster_oidc_provider_arn = module.eks.oidc_provider_arn
  vpc_id                    = module.vpc.vpc_id
  aws_region                = var.aws_region

  enable_metrics_server        = var.enable_metrics_server
  metrics_server_chart_version = var.metrics_server_chart_version

  enable_aws_load_balancer_controller        = var.enable_aws_load_balancer_controller
  aws_load_balancer_controller_chart_version = var.aws_load_balancer_controller_chart_version
  enable_aws_ebs_csi_driver                  = var.enable_aws_ebs_csi_driver
  enable_cert_manager                        = var.enable_cert_manager
  cert_manager_chart_version                 = var.cert_manager_chart_version

  tags = local.common_tags
}