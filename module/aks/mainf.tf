## Provisions the AKS cluster
resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = "${var.cluster_name}-dns"
  kubernetes_version  = var.cluster_version

  default_node_pool {
    name           = "default"
    node_count     = var.nodepool_min_count
    vm_size        = var.nodepool_vm_size
    vnet_subnet_id = var.vnet_subnet_id
    ## Enable autoscaling for the node pool
    auto_scaling_enabled = true
    min_count            = var.nodepool_min_count
    max_count            = var.nodepool_max_count
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin = "kubenet"
    service_cidr   = "10.240.0.0/16"
    dns_service_ip = "10.240.0.10"
    pod_cidr       = "10.244.0.0/16"
  }

  ## Enable OIDC Issuer, prerequisite for AAD Workload Identity
  workload_identity_enabled = true
  oidc_issuer_enabled = true
}


## --- Azure AD Workload Identity Configuration ---

## 1. Create an Application in Azure AD
resource "azuread_application" "workload_identity_app" {
  display_name = "${var.cluster_name}-workload-identity"
}

## 2. Create a Service Principal for the AAD application
resource "azuread_service_principal" "workload_identity_sp" {
  client_id = azuread_application.workload_identity_app.client_id
}

## 3. Create the Federated Identity Credential to link K8s to the AAD App
resource "azuread_application_federated_identity_credential" "fic" {
  application_id = azuread_application.workload_identity_app.id
  display_name   = "${var.cluster_name}-fic"

  ## The issuer is the OIDC from the AKS cluster
  issuer = azurerm_kubernetes_cluster.aks.oidc_issuer_url

  ## The "subject" identifies the specific ServiceAccount
  subject = "system:serviceaccount:${var.workload_identity_sa_namespace}:${var.workload_identity_sa_name}"

  audiences = ["api://AzureADTokenExchange"]
}

## 4. Permission assignment (Role Assignment)
resource "azurerm_role_assignment" "sp_role_assignment" {
  scope                = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = azuread_service_principal.workload_identity_sp.object_id
}


data "azurerm_client_config" "current" {}
