variable "name" {
  description = "Name of the search service. 2-60 characters, lowercase letters, numbers and hyphens. Globally unique."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{0,58}[a-z0-9]$", var.name))
    error_message = "The name must be 2-60 characters, lowercase letters, numbers and hyphens, starting and ending with a letter or number."
  }
}

variable "location" {
  description = "Azure region, e.g. \"westeurope\". Check feature and quota availability per region."
  type        = string
}

variable "resource_group_id" {
  description = "Resource ID of the resource group to deploy into, e.g. azurerm_resource_group.this.id."
  type        = string
}

variable "tags" {
  description = "Tags applied to all resources."
  type        = map(string)
  default     = {}
}

variable "sku_name" {
  description = "Service tier. Basic and above support private endpoints and semantic ranking. free is shared and has no private access."
  type        = string
  default     = "basic"

  validation {
    condition     = contains(["free", "basic", "standard", "standard2", "standard3", "storage_optimized_l1", "storage_optimized_l2"], var.sku_name)
    error_message = "Use one of free, basic, standard, standard2, standard3, storage_optimized_l1, storage_optimized_l2."
  }
}

variable "replica_count" {
  description = "Number of replicas. Two give read high availability, three give read/write high availability."
  type        = number
  default     = 1

  validation {
    condition     = var.replica_count >= 1 && var.replica_count <= 12
    error_message = "Use a value between 1 and 12."
  }
}

variable "partition_count" {
  description = "Number of partitions: 1, 2, 3, 4, 6 or 12. More partitions add storage and indexing throughput."
  type        = number
  default     = 1

  validation {
    condition     = contains([1, 2, 3, 4, 6, 12], var.partition_count)
    error_message = "Use 1, 2, 3, 4, 6 or 12."
  }
}

variable "semantic_search_sku" {
  description = "Semantic ranker plan: free or standard. Leave null to disable it. free has a monthly query limit."
  type        = string
  default     = null

  validation {
    condition     = var.semantic_search_sku == null || contains(["free", "standard"], coalesce(var.semantic_search_sku, "free"))
    error_message = "Use free, standard or null."
  }
}

variable "public_network_access_enabled" {
  description = "Allow public network access. False by default: reach the service through a private endpoint."
  type        = bool
  default     = false
}

variable "local_authentication_enabled" {
  description = "Allow API key authentication. False by default so only Microsoft Entra ID is accepted. Callers need roles such as \"Search Index Data Reader\"."
  type        = bool
  default     = false
}

variable "private_endpoint" {
  description = "Private endpoint for the service. Leave null to skip. An object (not separate strings) so its existence is known at plan time even when the subnet is created in the same apply. private_dns_zone_resource_ids takes e.g. privatelink.search.windows.net."
  type = object({
    subnet_resource_id            = string
    private_dns_zone_resource_ids = optional(list(string), [])
  })
  default = null
}

variable "diagnostics" {
  description = "Send diagnostic logs and metrics to a Log Analytics workspace. Leave null to skip diagnostics. An object (not a string) so its existence is known at plan time even when the workspace is created in the same apply."
  type = object({
    workspace_resource_id = string
  })
  default = null
}

variable "enable_system_assigned_identity" {
  description = "Enable the system-assigned managed identity, needed for indexers and integrated vectorization to reach other resources."
  type        = bool
  default     = true
}

variable "role_assignments" {
  description = "RBAC role assignments on the service, keyed by an arbitrary static name, e.g. \"Search Index Data Contributor\" for an ingestion identity."
  type = map(object({
    role_definition_id_or_name = string
    principal_id               = string
    principal_type             = optional(string)
    description                = optional(string)
  }))
  default = {}
}
