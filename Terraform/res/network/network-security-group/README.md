# Network security group

Network security group with typed rules. Wraps `Azure/avm-res-network-networksecuritygroup/azurerm` 0.5.1.

## Defaults

- An explicit `DenyAllInbound` rule at priority 4096, so the intent is visible in the portal and in reviews. Turn it off with `deny_all_inbound = false`.
- The deny-all at 4096 sits above Azure's default rules (65000+), so it also blocks inbound VNet-to-VNet traffic and Azure Load Balancer health probes that the defaults would allow. Add explicit allow rules with a priority below 4096 for whatever must reach the subnet (for example `VirtualNetwork` sources, or the `AzureLoadBalancer` tag for load-balanced workloads).

Associate the NSG with a subnet through the `network_security_group_resource_id` property of the virtual network module's subnets.

## Usage

```hcl
module "nsg" {
  source = "../../res/network/network-security-group"

  name              = "nsg-web"
  location          = "westeurope"
  resource_group_id = azurerm_resource_group.this.id

  security_rules = {
    allow_https_inbound = {
      name                       = "AllowHttpsInbound"
      access                     = "Allow"
      direction                  = "Inbound"
      priority                   = 100
      protocol                   = "Tcp"
      source_address_prefix      = "Internet"
      source_port_range          = "*"
      destination_address_prefix = "VirtualNetwork"
      destination_port_range     = "443"
    }
  }
}
```

## Tests

- [tests/defaults](tests/defaults/main.tf): HTTPS allow rule plus the default deny-all
