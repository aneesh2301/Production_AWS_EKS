output "metrics_server_enabled" {
  description = "Whether Metrics Server was installed"
  value       = var.enable_metrics_server
}

output "aws_lbc_role_arn" {
  description = "IAM role ARN used by AWS Load Balancer Controller (via IRSA)"
  value       = var.enable_aws_load_balancer_controller ? module.aws_load_balancer_controller_irsa[0].iam_role_arn : null
}

output "aws_ebs_role_arn" {
  description = "IAM role ARN used by AWS EBS CSI Driver (via IRSA)"
  value       = var.enable_aws_ebs_csi_driver ? module.ebs_csi_irsa[0].iam_role_arn : null
}

output "external_dns_role_arn" {
  description = "IAM role ARN used by ExternalDNS (via IRSA)"
  value       = var.enable_external_dns ? module.external_dns_irsa[0].iam_role_arn : null
}