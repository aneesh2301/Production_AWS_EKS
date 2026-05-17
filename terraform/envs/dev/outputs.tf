output "oidc_provider_arn" {
  description = "The ARN of the OIDC Provider"
  value       = module.eks.oidc_provider_arn
}

output "oidc_provider" {
  description = "The URL of the OIDC Provider"
  value       = module.eks.oidc_provider
}

output "cluster_name" {
  value = module.eks.cluster_id
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "kubeconfig_certificate_authority_data" {
  value = module.eks.cluster_certificate_authority_data
}

output "karpenter_node_iam_role_name" {
  description = "IAM role name referenced by the default Karpenter EC2NodeClass"
  value       = var.enable_karpenter ? module.karpenter[0].node_iam_role_name : null
}

output "karpenter_queue_name" {
  description = "SQS interruption queue used by Karpenter"
  value       = var.enable_karpenter ? module.karpenter[0].queue_name : null
}