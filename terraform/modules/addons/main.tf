# ── Metrics Server ────────────────────────────────────────────────────────────
# Provides CPU/memory metrics for pods and nodes.
# Required for HPA (Horizontal Pod Autoscaler) to function.
# No IRSA needed — reads metrics only from the kubelet API.

resource "helm_release" "metrics_server" {
  count = var.enable_metrics_server ? 1 : 0

  name       = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  namespace  = "kube-system"
  version    = var.metrics_server_chart_version

  # Run two replicas for HA — ensures metrics are available during node disruptions
  set {
    name  = "replicas"
    value = "2"
  }

  # Required on EKS — kubelet uses self-signed certs, skip CA verification
  set {
    name  = "args[0]"
    value = "--kubelet-insecure-tls"
  }
}

# ── AWS Load Balancer Controller ──────────────────────────────────────────────
# Manages ALB/NLB resources in AWS when Ingress or Service objects are created.
# Requires IRSA — it calls AWS APIs to create/configure load balancers.

module "aws_load_balancer_controller_irsa" {
  count = var.enable_aws_load_balancer_controller ? 1 : 0

  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.58.0"

  role_name = "${var.cluster_name}-aws-lbc"

  attach_load_balancer_controller_policy = true

  oidc_providers = {
    main = {
      provider_arn               = var.cluster_oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }

  tags = var.tags
}

resource "helm_release" "aws_load_balancer_controller" {
  count = var.enable_aws_load_balancer_controller ? 1 : 0

  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  version    = var.aws_load_balancer_controller_chart_version

  set {
    name  = "clusterName"
    value = var.cluster_name
  }

  # Point to the IRSA role — controller will assume this to call AWS APIs
  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.aws_load_balancer_controller_irsa[0].iam_role_arn
  }

  set {
    name  = "region"
    value = var.aws_region
  }

  set {
    name  = "vpcId"
    value = var.vpc_id
  }

  # Two replicas for HA — ensures ingress reconciliation continues during disruptions
  set {
    name  = "replicaCount"
    value = "2"
  }

  depends_on = [module.aws_load_balancer_controller_irsa]
}

# AWS EBS CSI Driver
# Manages EBS volumes for Kubernetes — required for dynamic provisioning of EBS-backed PersistentVolumes.

module "ebs_csi_irsa" {
  count = var.enable_aws_ebs_csi_driver ? 1 : 0

  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.58.0"

  role_name = "${var.cluster_name}-ebs-csi"

  attach_ebs_csi_policy = true

  oidc_providers = {
    this = {
      provider_arn               = var.cluster_oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }

  tags = var.tags
}

# ── External DNS ──────────────────────────────────────────────────────────────
# Manages Route53 DNS records for Kubernetes Services and Ingresses.
# Requires IRSA — it calls Route53 APIs to upsert and delete DNS records.

module "external_dns_irsa" {
  count = var.enable_external_dns ? 1 : 0

  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.58.0"

  role_name = "${var.cluster_name}-external-dns"

  attach_external_dns_policy    = true
  external_dns_hosted_zone_arns = var.external_dns_hosted_zone_arns

  oidc_providers = {
    main = {
      provider_arn               = var.cluster_oidc_provider_arn
      namespace_service_accounts = ["kube-system:external-dns"]
    }
  }

  tags = var.tags
}

resource "helm_release" "external_dns" {
  count = var.enable_external_dns ? 1 : 0

  name       = "external-dns"
  repository = "https://kubernetes-sigs.github.io/external-dns/"
  chart      = "external-dns"
  namespace  = "kube-system"
  version    = var.external_dns_chart_version

  values = [yamlencode({
    provider      = "aws"
    policy        = "upsert-only"
    registry      = "txt"
    txtOwnerId    = var.cluster_name
    sources       = ["ingress", "service"]
    domainFilters = var.external_dns_domain_filters
    serviceAccount = {
      create = true
      annotations = {
        "eks.amazonaws.com/role-arn" = module.external_dns_irsa[0].iam_role_arn
      }
    }
  })]

  depends_on = [module.external_dns_irsa]
}

# Cert-Manager deployement through Helm.

resource "helm_release" "cert_manager" {
  count = var.enable_cert_manager ? 1 : 0

  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  namespace  = "cert-manager"
  version    = var.cert_manager_chart_version

  create_namespace = true

  set {
    name  = "installCRDs"
    value = "true"
  }
}