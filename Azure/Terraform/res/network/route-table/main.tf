locals {
  resource_group_name = element(split("/", var.resource_group_id), 4)

  routes = {
    for route_name, route in var.routes : route_name => {
      name                   = route_name
      address_prefix         = route.address_prefix
      next_hop_type          = route.next_hop_type
      next_hop_in_ip_address = route.next_hop_in_ip_address
    }
  }
}

module "route_table" {
  source  = "Azure/avm-res-network-routetable/azurerm"
  version = "0.5.0"

  name                          = var.name
  location                      = var.location
  resource_group_name           = local.resource_group_name
  tags                          = var.tags
  routes                        = local.routes
  bgp_route_propagation_enabled = var.bgp_route_propagation_enabled
  role_assignments              = var.role_assignments
}
