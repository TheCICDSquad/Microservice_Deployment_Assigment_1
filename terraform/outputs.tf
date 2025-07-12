output "cluster_name" {
  description = "The name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group IDs attached to the cluster control plane"
  value       = module.eks.cluster_security_group_id
}

output "node_security_group_id" {
  description = "Security group IDs attached to the EKS worker nodes"
  value       = module.eks.node_security_group_id
}

output "eks_managed_node_groups" {
  description = "Outputs of EKS managed node groups"
  value       = module.eks.eks_managed_node_groups
}

output "helm_release_status" {
  description = "Status of the Helm release"
  value       = helm_release.currency_converter.status
}

output "helm_release_metadata" {
  description = "Metadata of the Helm release"
  value       = helm_release.currency_converter.metadata
}

output "hpa_name" {
  description = "Name of the Horizontal Pod Autoscaler"
  value       = kubernetes_horizontal_pod_autoscaler.currency_converter.metadata[0].name
}

output "hpa_status" {
  description = "Current status of the Horizontal Pod Autoscaler"
  value       = kubernetes_horizontal_pod_autoscaler.currency_converter.status[0]
}

output "application_endpoint" {
  description = "Endpoint to access the Currency Converter application"
  value       = "http://${kubernetes_service.currency_converter.status[0].load_balancer.ingress[0].hostname}"
  # Note: You'll need to define a kubernetes_service resource for your application to make this work
}