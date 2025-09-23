## Configure Azure and Azure Active Directory providers
provider "azurerm" {
  features {}
}

provider "azuread" {}

## Creation of prerequisite resources (Resource Group and Network)
resource "azurerm_resource_group" "rg" {
  name     = "rg-aks"
  location = "East US"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-aks"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "aks_subnet" {
  name                 = "snet-aks"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

module "my_aks_cluster" {
  source = "./module/aks" ## Path to the local module

  cluster_name        = "my-cluster-aks"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  vnet_subnet_id      = azurerm_subnet.aks_subnet.id

  ## Customizing autoscaling
  nodepool_min_count = 2
  nodepool_max_count = 5

  ## Defining the ServiceAccount that will receive the identity
  workload_identity_sa_name      = "my-pod-storage-reader"
  workload_identity_sa_namespace = "production"
}

resource "random_string" "storage_suffix" {
  length  = 5
  special = false
  upper   = false
}

resource "azurerm_storage_account" "demo" {
  name                     = "testaksidentity${random_string.storage_suffix.result}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "demo_container" {
  name                  = "demo-data"
  storage_account_id  = azurerm_storage_account.demo.id
  container_access_type = "private"
}

resource "azurerm_storage_blob" "demo_blob" {
  name                   = "test-file.txt"
  storage_account_name   = azurerm_storage_account.demo.name
  storage_container_name = azurerm_storage_container.demo_container.name
  type                   = "Block"
  source_content         = "AAD Workload Identity test successful!"
}