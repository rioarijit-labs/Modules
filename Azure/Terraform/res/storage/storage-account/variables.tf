variable "name" {
  description = "Name of the storage account. 3-24 characters, lowercase letters and numbers only."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]{3,24}$", var.name))
    error_message = "The name must be 3-24 lowercase letters and numbers."
  }
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
  description = "Tags applied to all resources."
  type        = map(string)
  default     = {}
}

variable "sku_name" {
  description = "Storage account SKU as <tier>_<replication>. Defaults to zone-redundant storage."
  type        = string
  default     = "Standard_ZRS"

  validation {
    condition = contains([
      "Standard_LRS", "Standard_ZRS", "Standard_GRS", "Standard_GZRS", "Standard_RAGRS", "Standard_RAGZRS",
      "Premium_LRS", "Premium_ZRS",
    ], var.sku_name)
    error_message = "Use one of Standard_LRS, Standard_ZRS, Standard_GRS, Standard_GZRS, Standard_RAGRS, Standard_RAGZRS, Premium_LRS, Premium_ZRS."
  }
}

variable "kind" {
  description = "Storage account kind."
  type        = string
  default     = "StorageV2"

  validation {
    condition     = contains(["StorageV2", "BlobStorage", "BlockBlobStorage", "FileStorage"], var.kind)
    error_message = "Use one of StorageV2, BlobStorage, BlockBlobStorage, FileStorage."
  }
}

variable "enable_hierarchical_namespace" {
  description = "Enable hierarchical namespace (Data Lake Storage Gen2)."
  type        = bool
  default     = false
}

variable "container_names" {
  description = "Names of private blob containers to create. Must be known at plan time."
  type        = set(string)
  default     = []
}

variable "soft_delete_retention_days" {
  description = "Days to retain deleted blobs and containers (soft delete)."
  type        = number
  default     = 7

  validation {
    condition     = var.soft_delete_retention_days >= 1 && var.soft_delete_retention_days <= 365
    error_message = "Use a value between 1 and 365."
  }
}

variable "public_network_access_enabled" {
  description = "Allow public network access. False by default: reach the data plane through a private endpoint."
  type        = bool
  default     = false
}

variable "private_endpoint" {
  description = <<-EOT
    Private endpoints for the storage services. Leave null to skip. An object (not separate strings) so its
    existence is known at plan time even when the subnet is created in the same apply.
    - subnet_resource_id: subnet for the endpoints.
    - services: blob, file, queue, table, dfs or web. Defaults to ["blob"].
    - private_dns_zone_resource_ids: private DNS zone ID keyed by service, e.g. { blob = "<privatelink.blob.core.windows.net zone ID>" }. Services without an entry get no DNS zone group.
  EOT
  type = object({
    subnet_resource_id            = string
    services                      = optional(set(string), ["blob"])
    private_dns_zone_resource_ids = optional(map(string), {})
  })
  default = null

  validation {
    condition     = var.private_endpoint == null || alltrue([for s in var.private_endpoint.services : contains(["blob", "file", "queue", "table", "dfs", "web"], s)])
    error_message = "services must be from blob, file, queue, table, dfs, web."
  }
}

variable "diagnostics" {
  description = "Send account metrics to a Log Analytics workspace. Leave null to skip diagnostics. An object (not a string) so its existence is known at plan time even when the workspace is created in the same apply."
  type = object({
    workspace_resource_id = string
  })
  default = null
}

variable "enable_system_assigned_identity" {
  description = "Enable the system-assigned managed identity."
  type        = bool
  default     = false
}

variable "user_assigned_identity_resource_ids" {
  description = "Resource IDs of user-assigned managed identities to attach."
  type        = set(string)
  default     = []
}

variable "role_assignments" {
  description = "RBAC role assignments on the storage account, keyed by an arbitrary static name, e.g. \"Storage Blob Data Reader\" for an app identity."
  type = map(object({
    role_definition_id_or_name = string
    principal_id               = string
    principal_type             = optional(string)
    description                = optional(string)
  }))
  default = {}
}
