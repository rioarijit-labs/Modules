# Azure Firewall

Managed network firewall for a hub virtual network. Wraps `Azure/avm-res-network-azurefirewall/azurerm` 0.4.0.

## Prerequisites

- The `subnet_resource_id` subnet must be named **exactly** `AzureFirewallSubnet`, at least `/26`. Create it with the `virtual-network` module — that subnet name is fixed by Azure, not something you choose.
- `firewall_policy_resource_id` is technically optional in the underlying resource, but a firewall with no policy has no rules and blocks everything. Deploy a [firewall-policy](../firewall-policy) alongside it in practice.
- `sku_tier` here must match the tier of the attached firewall policy.
- Unlike most modules in this repo, this one needs an explicit `public_ip_resource_id` — the AVM module doesn't create one for you.

## Getting the private IP without a sensitive value

The module's own `resource` output is marked sensitive by the upstream AVM module, so this wrapper reads the private IP back with a plain `data "azurerm_firewall"` lookup instead of deriving it from that sensitive output — otherwise the derived value would inherit the sensitive marking.

## Routing traffic through it

Deploying the firewall doesn't force any traffic through it. Point a [route-table](../route-table)'s default route (`0.0.0.0/0`, `next_hop_type = "VirtualAppliance"`) at this module's `private_ip_address` output, and associate that route table with the spoke subnets that should egress through the firewall.

## Usage

```hcl
module "firewall" {
  source = "../../res/network/azure-firewall"

  name                         = "afw-hub-001"
  location                     = "westeurope"
  resource_group_id            = azurerm_resource_group.this.id
  subnet_resource_id           = module.hub_network.subnet_resource_ids["azure_firewall"]
  public_ip_resource_id        = azurerm_public_ip.firewall.id
  firewall_policy_resource_id  = module.firewall_policy.resource_id
}

module "spoke_route_table" {
  source = "../../res/network/route-table"

  name              = "rt-spoke"
  location          = "westeurope"
  resource_group_id = azurerm_resource_group.this.id

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

- [tests/defaults](tests/defaults/main.tf): Standard tier in a hub VNet with a policy and diagnostics
