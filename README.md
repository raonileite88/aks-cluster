# Terraform Module for Azure Kubernetes Service (AKS)

[![Terraform Version](https://img.shields.io/badge/Terraform-~%3E%201.5-blue?logo=terraform)](https://www.terraform.io)
[![Azure Provider](https://img.shields.io/badge/Azure-Provider-blue.svg)](https://registry.terraform.io/providers/hashicorp/azurerm/latest)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)

This repository contains a Terraform project to deploy a secure and scalable Azure Kubernetes Service (AKS) cluster. It is structured as a root configuration that consumes a reusable child module (`./modules/aks`) to provision the core infrastructure.

The primary goal of this project is to establish a production-ready foundation for running containerized applications on Azure, with a strong focus on security and modern authentication practices.

***

## Architecture Overview

This Terraform code provisions the following core components in Azure:

1.  **Azure Resource Group:** A logical container to hold all related resources for the AKS cluster.
2.  **Virtual Network (VNet) & Subnet:** A dedicated network and subnet to provide an isolated network environment for the AKS worker nodes.
3.  **Azure Kubernetes Service (AKS) Cluster:** A managed Kubernetes cluster with the following key features:
    * **Autoscaling Node Pool:** The default node pool is configured to automatically scale the number of worker nodes based on workload demands.
    * **OIDC Issuer Enabled:** This is a prerequisite for using the modern, passwordless AAD Workload Identity.
4.  **Azure AD Workload Identity:** A secure authentication mechanism is configured to allow Kubernetes pods to access Azure resources (like Azure Storage) without needing to store any secrets or keys within the cluster. This is achieved by:
    * Creating an **Azure AD Application** and **Service Principal**.
    * Establishing a **Federated Credential** that links the AAD Application to a specific Kubernetes Service Account.
    * Assigning an **Azure Role** (e.g., "Storage Blob Data Reader") to the Service Principal, granting it specific permissions.

## Features

* **Reusable Module:** The AKS cluster and its dependencies are encapsulated in a reusable module (`./modules/aks`).
* **Secure Networking:** Deploys the cluster into a specified VNet and subnet.
* **Autoscaling:** The default node pool is configured with a minimum and maximum size for automatic scaling.
* **Secure Authentication:** Implements **Azure AD Workload Identity** for passwordless access from pods to Azure services.
* **Remote State Management:** The configuration is set up to use a secure Azure Blob Storage backend for Terraform state, enabling team collaboration and preventing state file loss.

## Prerequisites

Before you begin, ensure you have the following installed and configured:

1.  **Azure Subscription:** You must have an active Azure subscription.
2.  **Azure CLI:** [Install Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) and log in with `az login`.
3.  **Terraform:** [Install Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli) (version `~> 1.5` is recommended).
4.  **Azure Storage Account for Terraform State:** You must create a storage account to store the Terraform state file remotely and securely.
    * Create a Resource Group: `az group create --name rg-terraform-state --location "Brazil South"`
    * Create a Storage Account: `az storage account create --name tfstate<unique_string> --resource-group rg-terraform-state --sku Standard_LRS --encryption-services blob`
    * Create a Blob Container: `az storage container create --name tfstate --account-name tfstate<unique_string>`

## How to Use

### 1. Clone the Repository

```bash
git clone [https://github.com/raonileite88/aks-cluster.git](https://github.com/raonileite88/aks-cluster.git)
cd aks-cluster