variable "name" {
  description = "Name of the private endpoint."
  type        = string
}

variable "location" {
  description = "Azure region. Must match the region of the virtual network."
  type        = string
}

variable "resource_group_id" {
  description = "Resource ID of the resource group to deploy into, e.g. azurerm_resource_group.this.id."
  type        = string
}

variable "tags" {
  description = "Tags applied to the private endpoint."
  type        = map(string)
  default     = {}
}

variable "subnet_resource_id" {
  description = "Resource ID of the subnet the private endpoint network interface is placed in."
  type        = string
}

variable "private_link_service_resource_id" {
  description = "Resource ID of the target PaaS resource (storage account, Key Vault, web app, ...)."
  type        = string
}

variable "group_ids" {
  description = "Sub-resources (group IDs) to connect to, e.g. [\"blob\"], [\"vault\"], [\"sites\"], [\"account\"]."
  type        = list(string)

  validation {
    condition     = length(var.group_ids) > 0
    error_message = "Set at least one group ID."
  }
}

variable "private_dns_zone_resource_ids" {
  description = "Private DNS zone resource IDs to register the endpoint in, e.g. privatelink.blob.core.windows.net. Leave empty to manage DNS elsewhere."
  type        = list(string)
  default     = []
}
