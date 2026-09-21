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
  description = "Namespace tier. Private endpoints and network rules require Premium. Basic and Standard are public-only: set public_network_access_enabled to true with them."
  type        = string
  default     = "Premium"

  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.sku_name)
    error_message = "Use Basic, Standard or Premium."
  }
}

variable "premium_capacity" {
  description = "Messaging units for a Premium namespace: 1, 2, 4, 8 or 16. Ignored for other tiers."
  type        = number
  default     = 1

  validation {
    condition     = contains([1, 2, 4, 8, 16], var.premium_capacity)
    error_message = "Use 1, 2, 4, 8 or 16."
  }
}

variable "queues" {
  description = "Queues to create, keyed by queue name. lock_duration and default_message_ttl are ISO 8601 durations, e.g. \"PT1M\", \"P14D\"."
  type = map(object({
    max_delivery_count                   = optional(number, 10)
    lock_duration                        = optional(string, "PT1M")
    default_message_ttl                  = optional(string)
    dead_lettering_on_message_expiration = optional(bool, false)
    requires_session                     = optional(bool, false)
    requires_duplicate_detection         = optional(bool, false)
  }))
  default = {}
}

variable "topics" {
  description = "Topics to create, keyed by topic name, each with its subscriptions keyed by subscription name."
  type = map(object({
    default_message_ttl          = optional(string)
    requires_duplicate_detection = optional(bool, false)
    subscriptions = optional(map(object({
      max_delivery_count                   = optional(number, 10)
      lock_duration                        = optional(string, "PT1M")
      dead_lettering_on_message_expiration = optional(bool, false)
    })), {})
  }))
  default = {}
}

variable "public_network_access_enabled" {
  description = "Allow public network access. False by default: reach the namespace through a private endpoint (Premium)."
  type        = bool
  default     = false
}

variable "private_endpoint" {
  description = "Private endpoint for the namespace (Premium only). Leave null to skip. An object (not separate strings) so its existence is known at plan time even when the subnet is created in the same apply. private_dns_zone_resource_ids takes e.g. privatelink.servicebus.windows.net."
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
  description = "RBAC role assignments on the namespace, keyed by an arbitrary static name, e.g. \"Azure Service Bus Data Sender\" or \"Azure Service Bus Data Receiver\"."
  type = map(object({
    role_definition_id_or_name = string
    principal_id               = string
    principal_type             = optional(string)
    description                = optional(string)
  }))
  default = {}
}
