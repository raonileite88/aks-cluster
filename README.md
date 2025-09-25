# Terraform Module for Azure Kubernetes Service (AKS)

This repository contains a Terraform project to deploy a secure and scalable Azure Kubernetes Service (AKS) cluster. It is structured as a root configuration that consumes a reusable child module (`./modules/aks`) to provision the core infrastructure.

The primary goal of this project is to establish a production-ready foundation for running containerized applications on Azure, with a strong focus on security and modern authentication practices using **AAD Workload Identity**.

---

## Architecture Overview

This Terraform code provisions the following core components in Azure:

- **Azure Resource Group**: A logical container to hold all related resources.
- **Virtual Network (VNet) & Subnet**: A dedicated network for the AKS worker nodes.
- **Azure Kubernetes Service (AKS) Cluster**: A managed Kubernetes cluster with:
  - **Autoscaling Node Pool**: Automatically scales worker nodes based on demand.
  - **OIDC Issuer Enabled**: A prerequisite for using AAD Workload Identity.
  - **Azure AD Workload Identity**: A secure, passwordless authentication mechanism allowing Kubernetes pods to access Azure resources. This is achieved by:
    - Creating an Azure AD Application and Service Principal.
    - Establishing a Federated Credential linking the AAD Application to a specific Kubernetes Service Account.
    - Assigning an Azure Role (e.g., `"Storage Blob Data Reader"`) to the Service Principal.
- **Test Resources**: An Azure Storage Account, a container, and a test file (blob) are also created to verify the identity configuration.

---

## Features

- **Reusable Module**: The AKS cluster and its dependencies are encapsulated in a reusable module (`./modules/aks`).
- **Secure Networking**: Deploys the cluster into a specified VNet and subnet.
- **Autoscaling**: The default node pool is configured with a minimum and maximum size.
- **Secure Authentication**: Implements Azure AD Workload Identity for passwordless access from pods to Azure services.
- **Remote State Management**: Configured to use a secure Azure Blob Storage backend.
- **Automated Test Environment**: Automatically creates a storage account and test file to validate the deployment.

---

## Prerequisites

Before you begin, ensure you have the following installed and configured:

- **Azure Subscription**: An active Azure subscription.
- **Azure CLI**: Install Azure CLI and log in with `az login`.
- **Terraform**: Install Terraform (version `~> 1.5` is recommended).
- **Azure Storage Account for Terraform State**: You must create a storage account to store the Terraform state file remotely and securely.

```bash
# Create a Resource Group
az group create --name rg-terraform-state --location "Brazil South"

# Create a Storage Account
az storage account create --name tfstate<unique_string>   --resource-group rg-terraform-state   --sku Standard_LRS   --encryption-services blob

# Create a Blob Container
az storage container create --name tfstate --account-name tfstate<unique_string>
```

---

## How to Use

(Follow steps 1–4 to deploy the infrastructure before proceeding to the verification steps.)

### 1. Clone the Repository

```bash
git clone https://github.com/raonileite88/aks-cluster.git
cd aks-cluster
```

### 2. Configure the Backend

Open the **`backend.tf`** file and replace the placeholder values with the names of the resources you created in the prerequisites step.

### 3. Review `main.tf`

The **`main.tf`** file in the root of the project defines the values for the AKS cluster, including the `workload_identity_sa_name` and `workload_identity_sa_namespace`. Ensure these match your desired configuration.

### 4. Deploy the Infrastructure

Run the standard Terraform commands to initialize the project and deploy the resources.

```bash
terraform init
terraform apply
```

Enter **`yes`** when prompted to approve the deployment.

---

## Post-Deployment: Verifying AAD Workload Identity

After a successful `terraform apply`, follow these steps to deploy a test pod and verify that it can securely access the test storage account created by Terraform.

### 1. Connect to the AKS Cluster

```bash
# Get the resource group and cluster name from Terraform outputs
RESOURCE_GROUP_NAME=$(terraform output -raw resource_group_name)
CLUSTER_NAME=$(terraform output -raw cluster_name)

# Fetch credentials
az aks get-credentials --resource-group $RESOURCE_GROUP_NAME --name $CLUSTER_NAME --overwrite-existing
```

Verify the connection:

```bash
kubectl get nodes
```

### 2. Create the Kubernetes Manifest (`test-pod.yaml`)

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: my-pod-storage-reader      # MUST match 'workload_identity_sa_name' in main.tf
  namespace: production            # MUST match 'workload_identity_sa_namespace' in main.tf
  annotations:
    azure.workload.identity/client-id: "YOUR_WORKLOAD_IDENTITY_CLIENT_ID" # Placeholder
---
apiVersion: v1
kind: Pod
metadata:
  name: test-identity-pod
  namespace: production            # MUST match 'workload_identity_sa_namespace' in main.tf
  labels:
    azure.workload.identity/use: "true"
spec:
  serviceAccountName: my-pod-storage-reader
  containers:
    - name: azure-cli-container
      image: mcr.microsoft.com/azure-cli
      command: ["/bin/sh", "-c", "sleep 3600"]
```

### 3. Deploy the Test Pod

Get the Client ID from your Terraform deployment:

```bash
export WORKLOAD_CLIENT_ID=$(terraform output -raw workload_identity_client_id)
```

Replace the placeholder in your `test-pod.yaml` file:

```bash
sed -i "s/YOUR_WORKLOAD_IDENTITY_CLIENT_ID/$WORKLOAD_CLIENT_ID/" test-pod.yaml
```

Apply the manifest:

```bash
kubectl apply -f test-pod.yaml
```

### 4. Execute the Test Inside the Pod

Access the pod's shell:

```bash
kubectl exec -it test-identity-pod -n production -- /bin/bash
```

Inside the pod's shell, log in using its identity:

```bash
az login --service-principal -u $AZURE_CLIENT_ID -t $AZURE_TENANT_ID --federated-token "$(cat $AZURE_FEDERATED_TOKEN_FILE)"
```

Finally, attempt to access Azure Storage:

```bash
export STORAGE_ACCOUNT_NAME=$(terraform output -raw storage_account_name_for_demo)

# Run this inside the pod:
az storage blob list   --account-name $STORAGE_ACCOUNT_NAME   --container-name "demo-data"   --auth-mode login   --output table
```

If the command successfully returns a table listing **`test-file.txt`**, your test is complete!  
✅ You have verified that the AKS cluster can securely access Azure resources using AAD Workload Identity.

---

## How to Destroy the Infrastructure

When you are finished, you can destroy all the resources created by this project to avoid incurring further costs.

⚠️ **Warning**: This action is irreversible and will permanently delete all deployed resources.

```bash
terraform destroy
```

---

## Security Considerations

- **Remote State**: The Terraform state file (`.tfstate`) contains sensitive information. The backend storage account must be secured with restrictive network access and IAM policies.
- **No Hardcoded Secrets**: This repository is public. Do not commit any sensitive data, including secrets, keys, or `.tfvars` files.

---

## License

This project is licensed under the [MIT License](LICENSE).
