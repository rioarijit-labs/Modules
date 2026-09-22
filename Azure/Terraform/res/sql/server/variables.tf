variable "name" {
  description = "Name of the logical server. 1-63 characters, lowercase letters, numbers and hyphens. Globally unique."
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

variable "entra_admin_login" {
  description = "Display name of the Microsoft Entra administrator (a group is recommended), e.g. \"sql-admins\"."
  type        = string
}

variable "entra_admin_object_id" {
  description = "Object ID of the Microsoft Entra administrator."
  type        = string
}

variable "databases" {
  description = "Databases to create on the server, keyed by database name."
  type = map(object({
    sku_name       = string
    max_size_gb    = optional(number)
    zone_redundant = optional(bool)
  }))
  default = {}
}

variable "public_network_access_enabled" {
  description = "Allow public network access. False by default: reach the server through a private endpoint."
  type        = bool
  default     = false
}

variable "private_endpoint" {
  description = "Private endpoint for the server. Leave null to skip. An object (not separate strings) so its existence is known at plan time even when the subnet is created in the same apply. private_dns_zone_resource_ids takes e.g. privatelink.database.windows.net."
  type = object({
    subnet_resource_id            = string
    private_dns_zone_resource_ids = optional(list(string), [])
  })
  default = null
}

variable "enable_system_assigned_identity" {
  description = "Enable the system-assigned managed identity."
  type        = bool
  default     = true
}

variable "role_assignments" {
  description = "RBAC role assignments on the server resource (management plane), keyed by an arbitrary static name."
  type = map(object({
    role_definition_id_or_name = string
    principal_id               = string
    principal_type             = optional(string)
    description                = optional(string)
  }))
  default = {}
}
