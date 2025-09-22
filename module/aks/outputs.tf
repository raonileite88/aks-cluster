output "cluster_name" {
  description = "The name of the AKS cluster."
  value       = azurerm_kubernetes_cluster.aks.name
}

output "cluster_fqdn" {
  description = "The FQDN (endpoint) of the Kubernetes API server."
  value       = azurerm_kubernetes_cluster.aks.fqdn
}

output "kube_config_raw" {
  description = "The Kubeconfig content to access the cluster. Use with caution."
  value       = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive   = true
}

output "workload_identity_client_id" {
  description = "The Client ID of the AAD Application to be used in the ServiceAccount annotation."
  value       = azuread_application.workload_identity_app.client_id
}