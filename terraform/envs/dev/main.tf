module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.6.0"

  name = "eks-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["eu-west-3a", "eu-west-3b"]
  private_subnets = ["10.0.1.0/24","10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24","10.0.102.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true
}

data "aws_caller_identity" "current" {}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "21.0.3"

  cluster_name    = var.cluster_name
  cluster_version = "1.29"

  # Networking
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  # Public endpoint (for learning project)
  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = false

  # Enable IAM Roles for Service Accounts (VERY IMPORTANT)
  // Enables IAM Roles for Service Accounts (IRSA), allowing Kubernetes service accounts
  // to assume IAM roles with fine-grained permissions. This is the recommended approach
  // for granting AWS permissions to pods running in EKS clusters.
  // Supported in EKS v21 and later versions - not deprecated.
  enable_irsa = true

  # Cluster logging (production-like)
  cluster_enabled_log_types = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]

  # EKS Addons
  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  # Managed Node Group
  eks_managed_node_groups = {
    dev_nodes = {
      instance_types = ["t3.medium"]

      min_size     = 1
      max_size     = 2
      desired_size = 2

      capacity_type = "ON_DEMAND"

      # Attach nodes to private subnets
      subnet_ids = module.vpc.private_subnets
    }
  }
  # Access entries (modern replacement for aws-auth)
  access_entries = {
    cluster_admin = {
      principal_arn = data.aws_caller_identity.current.arn

      policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }

  tags = {
    Environment = "dev"
    Project     = "eks-production-project"
  }
}
