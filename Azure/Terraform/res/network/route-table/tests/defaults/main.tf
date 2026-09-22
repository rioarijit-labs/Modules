# Default route through a firewall appliance, with BGP propagation disabled.
provider "azurerm" {
  features {}
}

module "test" {
  source = "../../"

  name                          = "rt-defaults"
  location                      = "westeurope"
  resource_group_id             = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example"
  bgp_route_propagation_enabled = false

  routes = {
    default_via_firewall = {
      address_prefix         = "0.0.0.0/0"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = "10.0.0.4"
    }
  }
}
