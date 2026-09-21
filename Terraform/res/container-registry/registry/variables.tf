variable "name" {
  description = "Name of the registry. 5-50 characters, letters and numbers only. Globally unique."
  type        = string

  validation {
    condition     = can(regex("^[A-Za-z0-9]{5,50}$", var.name))
    error_message = "The name must be 5-50 letters and numbers."
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
  description = "Registry tier. Private endpoints, zone redundancy and the firewall need Premium. Basic and Standard are public-only: set public_network_access_enabled to true with them."
  type        = string
  default     = "Premium"

  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.sku_name)
    error_message = "Use Basic, Standard or Premium."
  }
}

variable "public_network_access_enabled" {
  description = "Allow public network access. False by default: push and pull through a private endpoint (Premium)."
  type        = bool
  default     = false
}

variable "zone_redundancy_enabled" {
  description = "Spread the registry across availability zones. Premium only."
  type        = bool
  default     = true
}

variable "private_endpoint" {
  description = "Private endpoint for the registry. Leave null to skip. An object (not separate strings) so its existence is known at plan time even when the subnet is created in the same apply. private_dns_zone_resource_ids takes e.g. privatelink.azurecr.io."
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
  description = "Enable the system-assigned managed identity."
  type        = bool
  default     = false
}

variable "role_assignments" {
  description = "RBAC role assignments on the registry, keyed by an arbitrary static name, e.g. \"AcrPull\" for a workload identity or \"AcrPush\" for a build pipeline."
  type = map(object({
    role_definition_id_or_name = string
    principal_id               = string
    principal_type             = optional(string)
    description                = optional(string)
  }))
  default = {}
}
