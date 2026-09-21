# Virtual network

Virtual network with typed subnets and peerings. Wraps `Azure/avm-res-network-virtualnetwork/azurerm` 0.22.2.

## Notes

- `subnets` and `peerings` are maps keyed by an arbitrary static name. The `subnet_resource_ids` output uses the same keys, so `module.network.subnet_resource_ids["private_endpoints"]` is the ID of the subnet declared under that key.
- Associate NSGs per subnet with `network_security_group_resource_id`. Do not associate one with `GatewaySubnet`.
- Subnets that host App Service VNet integration need `delegation = "Microsoft.Web/serverFarms"`.
- `create_reverse_peering = true` creates the reverse peering as well. The deploying identity needs write access on the remote network.
- Subnets default to no default outbound internet access (`default_outbound_access_enabled = false`).

## Usage

```hcl
module "network" {
  source = "../../res/network/virtual-network"

  name              = "vnet-spoke"
  location          = "westeurope"
  resource_group_id = azurerm_resource_group.this.id
  address_space     = ["10.10.0.0/16"]

  subnets = {
    workload = {
      name                               = "snet-workload"
      address_prefix                     = "10.10.0.0/24"
      network_security_group_resource_id = module.nsg.resource_id
    }
  }
}
```

## Tests

- [tests/defaults](tests/defaults/main.tf): workload, private endpoint and delegated integration subnets
