variable "name" {
  description = "Name of the route table."
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
  description = "Tags applied to the route table."
  type        = map(string)
  default     = {}
}

variable "routes" {
  description = "Routes, keyed by an arbitrary static name. next_hop_in_ip_address is required when next_hop_type is VirtualAppliance."
  type = map(object({
    address_prefix         = string
    next_hop_type          = string
    next_hop_in_ip_address = optional(string)
  }))
  default = {}
}

variable "bgp_route_propagation_enabled" {
  description = "Allow BGP-learned routes from a virtual network gateway to apply alongside this table. Set false on a route table that forces traffic through a firewall, so the gateway cannot bypass it."
  type        = bool
  default     = true
}

variable "role_assignments" {
  description = "RBAC role assignments on the route table, keyed by an arbitrary static name, e.g. \"Network Contributor\" for a platform team."
  type = map(object({
    role_definition_id_or_name = string
    principal_id               = string
    principal_type             = optional(string)
    description                = optional(string)
  }))
  default = {}
}
