module "vpc" {
  source = "../../modules/vpc"

  name                = "eks-vpc"
  cidr                = "10.0.0.0/16"
  azs                 = ["eu-west-3a", "eu-west-3b"]
  private_subnets     = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets      = ["10.0.101.0/24", "10.0.102.0/24"]
  enable_nat_gateway  = true
  single_nat_gateway  = true
  tags = {
    Environment = "dev"
    Project     = "eks-production-project"
  }
}

data "aws_caller_identity" "current" {}

module "eks" {
  source = "../../modules/eks"

  cluster_name    = var.cluster_name
  cluster_version = "1.29"

  # Networking — wired from VPC module outputs
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  # Public endpoint is acceptable for dev
  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = false

  enable_irsa = true

  cluster_enabled_log_types = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]

  cluster_addons = {
    coredns    = { most_recent = true }
    kube-proxy = { most_recent = true }
    vpc-cni    = { most_recent = true }
  }

  node_group = {
    name           = "dev-nodes"
    instance_types = ["t3.medium"]
    min_size       = 1
    max_size       = 2
    desired_size   = 2
    capacity_type  = "ON_DEMAND"
  }

  admin_principal_arn = data.aws_caller_identity.current.arn

  tags = {
    Environment = "dev"
    Project     = "eks-production-project"
  }
}