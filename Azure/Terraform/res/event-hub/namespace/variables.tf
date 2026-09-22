variable "name" {
  description = "Name of the namespace. 6-50 characters, letters, numbers and hyphens, starting with a letter. Globally unique."
  type        = string

  validation {
    condition     = can(regex("^[A-Za-z][A-Za-z0-9-]{4,48}[A-Za-z0-9]$", var.name))
    error_message = "The name must be 6-50 characters, letters, numbers and hyphens, starting with a letter and ending with a letter or number."
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
  description = "Namespace tier. Private endpoints need Standard or Premium. Basic is public-only: set public_network_access_enabled to true with it."
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.sku_name)
    error_message = "Use Basic, Standard or Premium."
  }
}

variable "capacity" {
  description = "Throughput units (Basic and Standard) or processing units (Premium)."
  type        = number
  default     = 1

  validation {
    condition     = var.capacity >= 1 && var.capacity <= 20
    error_message = "Use a value between 1 and 20."
  }
}

variable "auto_inflate_enabled" {
  description = "Automatically scale throughput units up to maximum_throughput_units. Standard only."
  type        = bool
  default     = false
}

variable "maximum_throughput_units" {
  description = "Upper limit for auto-inflate. Only used when auto_inflate_enabled is true."
  type        = number
  default     = null
}

variable "event_hubs" {
  description = <<-EOT
    Event hubs to create, keyed by event hub name.
    - partition_count: cannot be changed after creation on Basic and Standard, and bounds read parallelism.
    - message_retention_in_days: days events are retained. Standard allows up to 7.
    Consumer groups are not supported by the underlying AVM module yet.
  EOT
  type = map(object({
    partition_count           = optional(number, 2)
    message_retention_in_days = optional(number, 1)
  }))
  default = {}
}

variable "public_network_access_enabled" {
  description = "Allow public network access. False by default: reach the namespace through a private endpoint (Standard or Premium)."
  type        = bool
  default     = false
}

variable "private_endpoint" {
  description = "Private endpoint for the namespace. Leave null to skip. An object (not separate strings) so its existence is known at plan time even when the subnet is created in the same apply. private_dns_zone_resource_ids takes e.g. privatelink.servicebus.windows.net."
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
  description = "RBAC role assignments on the namespace, keyed by an arbitrary static name, e.g. \"Azure Event Hubs Data Sender\" or \"Azure Event Hubs Data Receiver\"."
  type = map(object({
    role_definition_id_or_name = string
    principal_id               = string
    principal_type             = optional(string)
    description                = optional(string)
  }))
  default = {}
}
