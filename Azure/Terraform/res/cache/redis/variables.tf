variable "name" {
  description = "Name of the cache. 1-63 characters, letters, numbers and hyphens."
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
  description = "Tags applied to all resources."
  type        = map(string)
  default     = {}
}

variable "sku_name" {
  description = "Tier. Basic has no SLA and no replication. Standard adds a replica for HA. Premium adds clustering, persistence, VNet injection and zone redundancy."
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.sku_name)
    error_message = "Use Basic, Standard or Premium."
  }
}

variable "capacity" {
  description = "Size within the tier: 0-6 for Basic/Standard (250 MB to 53 GB), 1-5 for Premium (6 GB to 120 GB)."
  type        = number
  default     = 1
}

variable "shard_count" {
  description = "Number of shards for clustering. Premium only, and only meaningful above 1."
  type        = number
  default     = null
}

variable "public_network_access_enabled" {
  description = "Allow public network access. False by default: reach the cache through a private endpoint (any tier) or VNet injection (Premium)."
  type        = bool
  default     = false
}

variable "access_keys_authentication_enabled" {
  description = "Allow access-key authentication. False by default so only Microsoft Entra ID is accepted. Grant access with role_assignments, e.g. \"Redis Cache Contributor\" for management."
  type        = bool
  default     = false
}

variable "private_endpoint" {
  description = "Private endpoint for the cache. Leave null to skip. An object (not separate strings) so its existence is known at plan time even when the subnet is created in the same apply. private_dns_zone_resource_ids takes e.g. privatelink.redis.cache.windows.net."
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
  description = "RBAC role assignments on the cache resource (management plane), keyed by an arbitrary static name, e.g. \"Redis Cache Contributor\"."
  type = map(object({
    role_definition_id_or_name = string
    principal_id               = string
    principal_type             = optional(string)
    description                = optional(string)
  }))
  default = {}
}
