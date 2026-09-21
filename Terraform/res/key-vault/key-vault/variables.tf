variable "name" {
  description = "Name of the vault. 3-24 characters, letters, numbers and hyphens, starting with a letter. Globally unique."
  type        = string

  validation {
    condition     = can(regex("^[A-Za-z][A-Za-z0-9-]{1,22}[A-Za-z0-9]$", var.name))
    error_message = "The name must be 3-24 characters, letters, numbers and hyphens, starting with a letter and ending with a letter or number."
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
  description = "Vault SKU. premium adds HSM-backed keys."
  type        = string
  default     = "standard"

  validation {
    condition     = contains(["standard", "premium"], var.sku_name)
    error_message = "Use standard or premium."
  }
}

variable "soft_delete_retention_days" {
  description = "Days deleted vault objects are retained before permanent deletion."
  type        = number
  default     = 90

  validation {
    condition     = var.soft_delete_retention_days >= 7 && var.soft_delete_retention_days <= 90
    error_message = "Use a value between 7 and 90."
  }
}

variable "purge_protection_enabled" {
  description = "Block permanent deletion until the retention period ends. This cannot be turned off once enabled, and the vault name stays reserved while a deleted vault is retained."
  type        = bool
  default     = true
}

variable "public_network_access_enabled" {
  description = "Allow public network access. False by default: reach the vault through a private endpoint."
  type        = bool
  default     = false
}

variable "private_endpoint" {
  description = "Private endpoint for the vault. Leave null to skip. An object (not separate strings) so its existence is known at plan time even when the subnet is created in the same apply. private_dns_zone_resource_ids takes e.g. privatelink.vaultcore.azure.net."
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

variable "role_assignments" {
  description = "RBAC role assignments on the vault, keyed by an arbitrary static name, e.g. \"Key Vault Secrets User\" for an app identity. The vault uses Azure RBAC, not access policies."
  type = map(object({
    role_definition_id_or_name = string
    principal_id               = string
    principal_type             = optional(string)
    description                = optional(string)
  }))
  default = {}
}
