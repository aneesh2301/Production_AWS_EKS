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
