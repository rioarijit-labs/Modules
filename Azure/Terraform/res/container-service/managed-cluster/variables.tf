variable "name" {
  description = "Name of the cluster. 1-63 characters."
  type        = string
}

variable "location" {
  description = "Azure region, e.g. \"westeurope\"."
  type        = string
}

variable "resource_group_id" {
  description = "Resource ID of the resource group to deploy into, e.g. azurerm_resource_group.this.id."
  type        = string
}

variable "tags" {
  description = "Tags applied to the cluster."
  type        = map(string)
  default     = {}
}

variable "dns_prefix" {
  description = "DNS prefix for the cluster, part of the API server's FQDN. Defaults to the cluster name."
  type        = string
  default     = null
}

variable "kubernetes_version" {
  description = "Kubernetes version, e.g. \"1.30\". Leave null to use AKS's current default."
  type        = string
  default     = null
}

variable "sku_tier" {
  description = "Free has no SLA. Standard and Premium add an uptime SLA; Premium adds long-term support windows."
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Free", "Standard", "Premium"], var.sku_tier)
    error_message = "Use Free, Standard or Premium."
  }
}

variable "system_node_pool" {
  description = "The initial system node pool. AKS requires at least one system pool for its own components."
  type = object({
    vm_size             = string
    count               = number
    enable_auto_scaling = optional(bool, false)
    min_count           = optional(number)
    max_count           = optional(number)
    subnet_resource_id  = string
    availability_zones  = optional(list(string))
  })
}

variable "additional_node_pools" {
  description = "Additional user node pools for application workloads, keyed by pool name."
  type = map(object({
    vm_size             = string
    count               = number
    enable_auto_scaling = optional(bool, false)
    min_count           = optional(number)
    max_count           = optional(number)
    subnet_resource_id  = string
    availability_zones  = optional(list(string))
  }))
  default = {}
}

variable "network_plugin" {
  description = "Azure CNI gives pods routable VNet IPs (needed for private endpoint access from pods, and for network policy). Kubenet is simpler but more limited."
  type        = string
  default     = "azure"

  validation {
    condition     = contains(["azure", "kubenet"], var.network_plugin)
    error_message = "Use azure or kubenet."
  }
}

variable "network_policy" {
  description = "Enforce Kubernetes NetworkPolicy (pod-to-pod traffic rules) using Azure's own implementation."
  type        = string
  default     = "azure"
}

variable "enable_private_cluster" {
  description = "No public API server endpoint; reach it from inside the VNet, over VPN/ExpressRoute, or through a jump host. Set to false only for a lab where that's inconvenient."
  type        = bool
  default     = true
}

variable "admin_group_object_ids" {
  description = "Microsoft Entra ID object IDs (users or groups) granted cluster-admin Kubernetes RBAC."
  type        = list(string)
  default     = []
}

variable "enable_workload_identity" {
  description = "Enable workload identity federation, so pods authenticate to Azure with a federated Entra ID credential instead of a stored secret. Pair with the managed-identity module's federated_identity_credentials, using this cluster's oidc_issuer_url output as the issuer."
  type        = bool
  default     = true
}

variable "enable_key_vault_secrets_provider" {
  description = "Enable the Key Vault Secrets Provider CSI driver, so pods can mount Key Vault secrets as files without an SDK."
  type        = bool
  default     = true
}

variable "monitoring_workspace_resource_id" {
  description = "Log Analytics workspace resource ID for Container Insights. Leave empty to skip."
  type        = string
  default     = ""
}

variable "enable_system_assigned_identity" {
  description = "Enable the system-assigned managed identity for the cluster's own control plane."
  type        = bool
  default     = true
}

variable "user_assigned_identity_resource_ids" {
  description = "Resource IDs of user-assigned managed identities to attach to the cluster control plane."
  type        = set(string)
  default     = []
}

variable "role_assignments" {
  description = "Azure RBAC role assignments on the cluster resource, keyed by an arbitrary static name, e.g. \"Azure Kubernetes Service RBAC Cluster Admin\" for an admin group."
  type = map(object({
    role_definition_id_or_name = string
    principal_id               = string
    principal_type             = optional(string)
    description                = optional(string)
  }))
  default = {}
}
