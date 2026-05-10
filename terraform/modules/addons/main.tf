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

# Fetch the official AWS-managed IAM policy document for the LBC
data "aws_iam_policy_document" "aws_lbc" {
  count = var.enable_aws_load_balancer_controller ? 1 : 0

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [var.cluster_oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(var.cluster_oidc_provider_arn, "/^(.*provider/)/", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(var.cluster_oidc_provider_arn, "/^(.*provider/)/", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "aws_lbc" {
  count = var.enable_aws_load_balancer_controller ? 1 : 0

  name               = "${var.cluster_name}-aws-lbc"
  assume_role_policy = data.aws_iam_policy_document.aws_lbc[0].json

  tags = var.tags
}

# Download the official AWS LBC IAM policy JSON directly from GitHub
data "http" "aws_lbc_iam_policy" {
  count = var.enable_aws_load_balancer_controller ? 1 : 0
  url   = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.8.1/docs/install/iam_policy.json"
}

resource "aws_iam_policy" "aws_lbc" {
  count = var.enable_aws_load_balancer_controller ? 1 : 0

  name        = "${var.cluster_name}-aws-lbc-policy"
  description = "IAM policy for AWS Load Balancer Controller"
  policy      = data.http.aws_lbc_iam_policy[0].response_body

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "aws_lbc" {
  count = var.enable_aws_load_balancer_controller ? 1 : 0

  role       = aws_iam_role.aws_lbc[0].name
  policy_arn = aws_iam_policy.aws_lbc[0].arn
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
    value = aws_iam_role.aws_lbc[0].arn
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

  depends_on = [aws_iam_role_policy_attachment.aws_lbc]
}
