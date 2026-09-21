variable "name" {
  description = "Name of the App Service plan."
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

variable "os_type" {
  description = "Operating system of the plan. Windows and Linux apps cannot share a plan."
  type        = string
  default     = "Linux"

  validation {
    condition     = contains(["Linux", "Windows"], var.os_type)
    error_message = "Use Linux or Windows."
  }
}

variable "sku_name" {
  description = "Pricing SKU, e.g. \"B1\", \"P1v3\", \"P0v3\", \"S1\". Zone balancing requires a Premium v2/v3 SKU."
  type        = string
  default     = "P1v3"
}

variable "worker_count" {
  description = "Number of instances. Zone balancing requires at least 3."
  type        = number
  default     = 1

  validation {
    condition     = var.worker_count >= 1 && var.worker_count <= 30
    error_message = "Use a value between 1 and 30."
  }
}

variable "zone_balancing_enabled" {
  description = "Spread instances across availability zones. Needs a Premium v2/v3 SKU and at least 3 instances."
  type        = bool
  default     = false
}

variable "diagnostics" {
  description = "Send diagnostic logs and metrics to a Log Analytics workspace. Leave null to skip diagnostics. An object (not a string) so its existence is known at plan time even when the workspace is created in the same apply."
  type = object({
    workspace_resource_id = string
  })
  default = null
}
