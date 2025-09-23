Terraform Module for Azure Kubernetes Service (AKS)
===================================================

This repository contains a Terraform project to deploy a secure and scalable Azure Kubernetes Service (AKS) cluster. It is structured as a root configuration that consumes a reusable child module (./modules/aks) to provision the core infrastructure.

The primary goal of this project is to establish a production-ready foundation for running containerized applications on Azure, with a strong focus on security and modern authentication practices using AAD Workload Identity.

Architecture Overview
---------------------

This Terraform code provisions the following core components in Azure:

1.  **Azure Resource Group:** A logical container to hold all related resources.
    
2.  **Virtual Network (VNet) & Subnet:** A dedicated network for the AKS worker nodes.
    
3.  **Azure Kubernetes Service (AKS) Cluster:** A managed Kubernetes cluster with:
    
    *   **Autoscaling Node Pool:** Automatically scales worker nodes based on demand.
        
    *   **OIDC Issuer Enabled:** A prerequisite for using AAD Workload Identity.
        
4.  **Azure AD Workload Identity:** A secure, passwordless authentication mechanism allowing Kubernetes pods to access Azure resources. This is achieved by:
    
    *   Creating an **Azure AD Application** and **Service Principal**.
        
    *   Establishing a **Federated Credential** linking the AAD Application to a specific Kubernetes Service Account.
        
    *   Assigning an **Azure Role** (e.g., "Storage Blob Data Reader") to the Service Principal.
        
5.  **Test Resources:** An Azure Storage Account, a container, and a test file (blob) are also created to verify the identity configuration.
    

Features
--------

*   **Reusable Module:** The AKS cluster and its dependencies are encapsulated in a reusable module (./modules/aks).
    
*   **Secure Networking:** Deploys the cluster into a specified VNet and subnet.
    
*   **Autoscaling:** The default node pool is configured with a minimum and maximum size.
    
*   **Secure Authentication:** Implements **Azure AD Workload Identity** for passwordless access from pods to Azure services.
    
*   **Remote State Management:** Configured to use a secure Azure Blob Storage backend.
    
*   **Automated Test Environment:** Automatically creates a storage account and test file to validate the deployment.
    

Prerequisites
-------------

Before you begin, ensure you have the following installed and configured:

1.  **Azure Subscription:** An active Azure subscription.
    
2.  **Azure CLI:** [Install Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) and log in with az login.
    
3.  **Terraform:** [Install Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli) (version ~> 1.5 is recommended).
    
4.  **Azure Storage Account for Terraform State:** You must create a storage account to store the Terraform state file remotely and securely.
    
    *   Create a Resource Group: az group create --name rg-terraform-state --location "Brazil South"
        
    *   Create a Storage Account: az storage account create --name tfstate --resource-group rg-terraform-state --sku Standard\_LRS --encryption-services blob
        
    *   Create a Blob Container: az storage container create --name tfstate --account-name tfstate
        

How to Use
----------

_(Follow steps 1-4 to deploy the infrastructure before proceeding to the verification steps.)_

### 1\. Clone the Repository

Bash

Plain textANTLR4BashCC#CSSCoffeeScriptCMakeDartDjangoDockerEJSErlangGitGoGraphQLGroovyHTMLJavaJavaScriptJSONJSXKotlinLaTeXLessLuaMakefileMarkdownMATLABMarkupObjective-CPerlPHPPowerShell.propertiesProtocol BuffersPythonRRubySass (Sass)Sass (Scss)SchemeSQLShellSwiftSVGTSXTypeScriptWebAssemblyYAMLXML`   git clone https://github.com/raonileite88/aks-cluster.git  cd aks-cluster   `

### 2\. Configure the Backend

Open the backend.tf file and replace the placeholder values with the names of the resources you created in the prerequisites step.

### 3\. Review main.tf

The main.tf file in the root of the project defines the values for the AKS cluster, including the workload\_identity\_sa\_name and workload\_identity\_sa\_namespace. Ensure these match your desired configuration.

### 4\. Deploy the Infrastructure

Run the standard Terraform commands to initialize the project and deploy the resources.

Bash

Plain textANTLR4BashCC#CSSCoffeeScriptCMakeDartDjangoDockerEJSErlangGitGoGraphQLGroovyHTMLJavaJavaScriptJSONJSXKotlinLaTeXLessLuaMakefileMarkdownMATLABMarkupObjective-CPerlPHPPowerShell.propertiesProtocol BuffersPythonRRubySass (Sass)Sass (Scss)SchemeSQLShellSwiftSVGTSXTypeScriptWebAssemblyYAMLXML`   terraform init  terraform apply   `

Enter yes when prompted to approve the deployment.

Post-Deployment: Verifying AAD Workload Identity
------------------------------------------------

After a successful terraform apply, follow these steps to deploy a test pod and verify that it can securely access the test storage account created by Terraform.

### 1\. Connect to the AKS Cluster

Use the Azure CLI to fetch the cluster credentials. This command will merge them into your local ~/.kube/config file.

Bash

Plain textANTLR4BashCC#CSSCoffeeScriptCMakeDartDjangoDockerEJSErlangGitGoGraphQLGroovyHTMLJavaJavaScriptJSONJSXKotlinLaTeXLessLuaMakefileMarkdownMATLABMarkupObjective-CPerlPHPPowerShell.propertiesProtocol BuffersPythonRRubySass (Sass)Sass (Scss)SchemeSQLShellSwiftSVGTSXTypeScriptWebAssemblyYAMLXML`   # Get the resource group and cluster name from Terraform outputs  RESOURCE_GROUP_NAME=$(terraform output -raw resource_group_name)  CLUSTER_NAME=$(terraform output -raw cluster_name)  # Fetch credentials  az aks get-credentials --resource-group $RESOURCE_GROUP_NAME --name $CLUSTER_NAME --overwrite-existing   `

Verify the connection:

Bash

Plain textANTLR4BashCC#CSSCoffeeScriptCMakeDartDjangoDockerEJSErlangGitGoGraphQLGroovyHTMLJavaJavaScriptJSONJSXKotlinLaTeXLessLuaMakefileMarkdownMATLABMarkupObjective-CPerlPHPPowerShell.propertiesProtocol BuffersPythonRRubySass (Sass)Sass (Scss)SchemeSQLShellSwiftSVGTSXTypeScriptWebAssemblyYAMLXML`   kubectl get nodes   `

### 2\. Create the Kubernetes Manifest (test-pod.yaml)

Create a file named test-pod.yaml. This file defines a ServiceAccount linked to your Azure AD identity and a test pod that uses it.

YAML

Plain textANTLR4BashCC#CSSCoffeeScriptCMakeDartDjangoDockerEJSErlangGitGoGraphQLGroovyHTMLJavaJavaScriptJSONJSXKotlinLaTeXLessLuaMakefileMarkdownMATLABMarkupObjective-CPerlPHPPowerShell.propertiesProtocol BuffersPythonRRubySass (Sass)Sass (Scss)SchemeSQLShellSwiftSVGTSXTypeScriptWebAssemblyYAMLXML`   apiVersion: v1  kind: ServiceAccount  metadata:    name: my-pod-storage-reader      # This MUST match 'workload_identity_sa_name' in your main.tf    namespace: production             # This MUST match 'workload_identity_sa_namespace' in your main.tf    annotations:      azure.workload.identity/client-id: "YOUR_WORKLOAD_IDENTITY_CLIENT_ID" # Placeholder  ---  apiVersion: v1  kind: Pod  metadata:    name: test-identity-pod    namespace: production             # This MUST match 'workload_identity_sa_namespace' in your main.tf    labels:      azure.workload.identity/use: "true"  spec:    serviceAccountName: my-pod-storage-reader    containers:      - name: azure-cli-container        image: mcr.microsoft.com/azure-cli        command: ["/bin/sh", "-c", "sleep 3600"]   `

### 3\. Deploy the Test Pod

1.  Bashexport WORKLOAD\_CLIENT\_ID=$(terraform output -raw workload\_identity\_client\_id)
    
2.  Bashsed -i "s/YOUR\_WORKLOAD\_IDENTITY\_CLIENT\_ID/$WORKLOAD\_CLIENT\_ID/" test-pod.yaml
    
3.  Bashkubectl apply -f test-pod.yaml
    

### 4\. Execute the Test Inside the Pod

1.  Bashkubectl exec -it test-identity-pod -n production -- /bin/bash
    
2.  Bashaz login --service-principal -u $AZURE\_CLIENT\_ID -t $AZURE\_TENANT\_ID --federated-token "$(cat $AZURE\_FEDERATED\_TOKEN\_FILE)"A successful login will return a JSON object describing the authenticated session.
    
3.  Bashexport STORAGE\_ACCOUNT\_NAME=$(terraform output -raw storage\_account\_name\_for\_demo)# Now, run this command inside the pod:az storage blob list --account-name $STORAGE\_ACCOUNT\_NAME --container-name "demo-data" --auth-mode login --output table
    

If the command successfully returns a table listing test-file.txt, your test is complete! You have verified that the AKS cluster can securely access Azure resources using AAD Workload Identity.

How to Destroy the Infrastructure
---------------------------------

When you are finished, you can destroy all the resources created by this project to avoid incurring further costs.

**Warning:** This action is irreversible and will permanently delete all deployed resources.

Bash

Plain textANTLR4BashCC#CSSCoffeeScriptCMakeDartDjangoDockerEJSErlangGitGoGraphQLGroovyHTMLJavaJavaScriptJSONJSXKotlinLaTeXLessLuaMakefileMarkdownMATLABMarkupObjective-CPerlPHPPowerShell.propertiesProtocol BuffersPythonRRubySass (Sass)Sass (Scss)SchemeSQLShellSwiftSVGTSXTypeScriptWebAssemblyYAMLXML`   terraform destroy   `

Security Considerations
-----------------------

*   **Remote State:** The Terraform state file (.tfstate) contains sensitive information. The backend storage account must be secured with restrictive network access and IAM policies.
    
*   **No Hardcoded Secrets:** This repository is public. Do not commit any sensitive data, including secrets, keys, or .tfvars files.
    

License
-------

This project is licensed under the MIT License.