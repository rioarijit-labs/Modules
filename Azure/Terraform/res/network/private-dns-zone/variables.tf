variable "name" {
  description = "Name of the zone, e.g. \"privatelink.blob.core.windows.net\". Use the exact privatelink name for the service, it is not free-form."
  type        = string
}

variable "resource_group_id" {
  description = "Resource ID of the resource group to deploy into, e.g. azurerm_resource_group.this.id."
  type        = string
}

variable "tags" {
  description = "Tags applied to the zone and its links."
  type        = map(string)
  default     = {}
}

variable "virtual_network_resource_ids" {
  description = "Virtual networks to link to the zone, as a map of link name to virtual network resource ID, e.g. { hub = module.hub.resource_id }. The key must be known at plan time, the value may be computed."
  type        = map(string)
  default     = {}
}

variable "registration_enabled" {
  description = "Enable auto-registration of VM records from the linked networks. Leave false for private endpoint zones."
  type        = bool
  default     = false
}
