output "metrics_server_enabled" {
  description = "Whether Metrics Server was installed"
  value       = var.enable_metrics_server
}

output "aws_lbc_role_arn" {
  description = "IAM role ARN used by AWS Load Balancer Controller (via IRSA)"
  value       = var.enable_aws_load_balancer_controller ? module.aws_load_balancer_controller_irsa[0].iam_role_arn : null
}
