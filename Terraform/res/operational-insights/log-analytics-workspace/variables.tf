variable "name" {
  description = "Name of the workspace. 4-63 characters, letters, numbers and hyphens."
  type        = string

  validation {
    condition     = can(regex("^[A-Za-z0-9][A-Za-z0-9-]{2,61}[A-Za-z0-9]$", var.name))
    error_message = "The name must be 4-63 characters, letters, numbers and hyphens, starting and ending with a letter or number."
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
  description = "Tags applied to the workspace."
  type        = map(string)
  default     = {}
}

variable "sku_name" {
  description = "Pricing SKU. PerGB2018 is pay-as-you-go."
  type        = string
  default     = "PerGB2018"

  validation {
    condition     = contains(["PerGB2018", "CapacityReservation", "Free"], var.sku_name)
    error_message = "Use one of PerGB2018, CapacityReservation, Free."
  }
}

variable "retention_in_days" {
  description = "Days to retain data in the workspace. 30 is included in the price for most tables."
  type        = number
  default     = 30

  validation {
    condition     = var.retention_in_days >= 4 && var.retention_in_days <= 730
    error_message = "Use a value between 4 and 730."
  }
}

variable "daily_quota_gb" {
  description = "Daily ingestion cap in GB, decimals allowed (e.g. 0.5). -1 means no cap. A cap protects cost but drops data once reached."
  type        = number
  default     = -1
}

variable "internet_ingestion_enabled" {
  description = "Allow data ingestion over the public network. Disabling it requires an Azure Monitor Private Link Scope, otherwise diagnostics from other resources stop arriving."
  type        = bool
  default     = true
}

variable "internet_query_enabled" {
  description = "Allow queries over the public network. Disabling it requires an Azure Monitor Private Link Scope."
  type        = bool
  default     = true
}

variable "role_assignments" {
  description = "RBAC role assignments on the workspace, keyed by an arbitrary static name, e.g. \"Log Analytics Reader\" for a support group."
  type = map(object({
    role_definition_id_or_name = string
    principal_id               = string
    principal_type             = optional(string)
    description                = optional(string)
  }))
  default = {}
}
