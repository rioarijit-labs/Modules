variable "name" {
  description = "Name of the virtual network."
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
  description = "Tags applied to the virtual network."
  type        = map(string)
  default     = {}
}

variable "address_space" {
  description = "Address space in CIDR notation, e.g. [\"10.10.0.0/16\"]."
  type        = list(string)

  validation {
    condition     = length(var.address_space) > 0
    error_message = "Set at least one address prefix."
  }
}

variable "subnets" {
  description = <<-EOT
    Subnets to create, keyed by an arbitrary static name.
    - address_prefix: CIDR inside the address space, e.g. "10.0.1.0/24".
    - network_security_group_resource_id: NSG to associate. Recommended for every subnet except those where Azure forbids it (e.g. GatewaySubnet).
    - delegation: service the subnet is delegated to, e.g. "Microsoft.Web/serverFarms" for App Service VNet integration.
    - service_endpoints: e.g. ["Microsoft.Storage"]. Prefer private endpoints.
    - private_endpoint_network_policies: Disabled, Enabled, NetworkSecurityGroupEnabled or RouteTableEnabled.
    - route_table_resource_id: route table to associate.
    - default_outbound_access_enabled: set false to disable default outbound internet access.
  EOT
  type = map(object({
    name                               = string
    address_prefix                     = string
    network_security_group_resource_id = optional(string)
    delegation                         = optional(string)
    service_endpoints                  = optional(set(string))
    private_endpoint_network_policies  = optional(string, "Enabled")
    route_table_resource_id            = optional(string)
    default_outbound_access_enabled    = optional(bool, false)
  }))
  default = {}
}

variable "dns_servers" {
  description = "Custom DNS server IP addresses. Leave empty to use Azure-provided DNS."
  type        = list(string)
  default     = []
}

variable "peerings" {
  description = <<-EOT
    Peerings to remote virtual networks, keyed by peering name.
    - create_reverse_peering: also create the peering from the remote network. The deploying identity needs write access to the remote network.
  EOT
  type = map(object({
    remote_virtual_network_resource_id = string
    allow_forwarded_traffic            = optional(bool, false)
    allow_gateway_transit              = optional(bool, false)
    allow_virtual_network_access       = optional(bool, true)
    use_remote_gateways                = optional(bool, false)
    create_reverse_peering             = optional(bool, false)
  }))
  default = {}
}

variable "diagnostics" {
  description = "Send diagnostic logs and metrics to a Log Analytics workspace. Leave null to skip diagnostics. An object (not a string) so its existence is known at plan time even when the workspace is created in the same apply."
  type = object({
    workspace_resource_id = string
  })
  default = null
}
