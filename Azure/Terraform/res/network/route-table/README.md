# Route table

Route table with user-defined routes. Wraps `Azure/avm-res-network-routetable/azurerm` 0.5.0.

## Notes

- Associate the table with a subnet through the `virtual-network` module's `route_table_resource_id` on that subnet.
- `bgp_route_propagation_enabled = false` stops a VPN or ExpressRoute gateway's BGP-learned routes from overriding your route table — set it on any subnet where traffic must go through a firewall, so the gateway can't bypass it.
- `next_hop_in_ip_address` is required only when `next_hop_type` is `VirtualAppliance` (pointing at a firewall or NVA's private IP).

## Usage

```hcl
module "route_table" {
  source = "../../res/network/route-table"

  name              = "rt-spoke"
  location          = "westeurope"
  resource_group_id = azurerm_resource_group.this.id
  bgp_route_propagation_enabled = false

  routes = {
    default_via_firewall = {
      address_prefix         = "0.0.0.0/0"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = module.firewall.private_ip_address
    }
  }
}
```

## Tests

- [tests/defaults](tests/defaults/main.tf): default route through a firewall appliance
