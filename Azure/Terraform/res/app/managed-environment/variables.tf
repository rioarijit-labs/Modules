variable "name" {
  description = "Name of the Container Apps environment."
  type        = string

  validation {
    condition     = length(var.name) >= 2 && length(var.name) <= 60
    error_message = "The name must be 2-60 characters."
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

variable "infrastructure_subnet_resource_id" {
  description = "Subnet resource ID for the environment infrastructure. It must be delegated to Microsoft.App/environments and be at least /27. Leave null for a non-VNet environment."
  type        = string
  default     = null
}

variable "internal" {
  description = "Internal load balancer: apps get a private IP and are only reachable from the VNet. Only applies when infrastructure_subnet_resource_id is set."
  type        = bool
  default     = true
}

variable "zone_redundant" {
  description = "Spread the environment across availability zones. Requires infrastructure_subnet_resource_id."
  type        = bool
  default     = false
}

variable "public_network_access_enabled" {
  description = "Allow public network access. False by default: reach the environment from the VNet."
  type        = bool
  default     = false
}

variable "diagnostics" {
  description = "Send the environment logs to a Log Analytics workspace. Leave null to skip logging. An object (not a string) so its existence is known at plan time even when the workspace is created in the same apply."
  type = object({
    workspace_resource_id = string
  })
  default = null
}
