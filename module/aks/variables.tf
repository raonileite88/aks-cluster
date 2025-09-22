variable "cluster_name" {
  description = "The name of the AKS cluster."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the Resource Group where the cluster will be created."
  type        = string
}

variable "location" {
  description = "The Azure location (region) to provision resources."
  type        = string
  default     = "eastus"
}

variable "cluster_version" {
  description = "The Kubernetes version for the AKS cluster."
  type        = string
  default     = "1.32.7"
}

variable "vnet_subnet_id" {
  description = "The ID of the VNet subnet where AKS nodes will be integrated."
  type        = string
}

variable "nodepool_vm_size" {
  description = "The VM size for AKS nodes."
  type        = string
  default     = "Standard_DS2_v2"
}

variable "nodepool_min_count" {
  description = "The minimum number of nodes for autoscaling."
  type        = number
  default     = 1
}

variable "nodepool_max_count" {
  description = "The maximum number of nodes for autoscaling."
  type        = number
  default     = 3
}

variable "workload_identity_sa_name" {
  description = "The name of the Kubernetes ServiceAccount that will use Workload Identity."
  type        = string
  default     = "my-app-sa"
}

variable "workload_identity_sa_namespace" {
  description = "The namespace of the Kubernetes ServiceAccount."
  type        = string
  default     = "default"
}