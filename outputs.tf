output "workload_identity_client_id" {
  description = "The Client ID of the AAD Application for the Workload Identity."
  # Certifique-se de que 'my_aks_cluster' é o nome que você deu ao módulo no seu main.tf
  value       = module.my_aks_cluster.workload_identity_client_id
}

output "resource_group_name" {
  description = "The name of the main resource group for the AKS cluster."
  value       = azurerm_resource_group.rg.name
}

output "cluster_name" {
  description = "The name of the created AKS cluster."
  # Certifique-se de que 'my_aks_cluster' é o nome que você deu ao módulo no seu main.tf
  value       = module.my_aks_cluster.cluster_name
}

output "storage_account_name_for_demo" {
  description = "The name of the storage account created for the demo."
  # Certifique-se de que 'azurerm_storage_account.demo' corresponde ao nome do recurso no seu main.tf
  value       = azurerm_storage_account.demo.name
}