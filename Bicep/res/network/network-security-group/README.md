# Network security group

Network security group with typed rules. Wraps `br/public:avm/res/network/network-security-group:0.5.3`.

## Defaults

- An explicit `DenyAllInbound` rule at priority 4096, so the intent is visible in the portal and in reviews. Turn it off with `denyAllInbound: false`.
- The deny-all at 4096 sits above Azure's default rules (65000+), so it also blocks inbound VNet-to-VNet traffic and Azure Load Balancer health probes that the defaults would allow. Add explicit allow rules with a priority below 4096 for whatever must reach the subnet (for example `VirtualNetwork` sources, or the `AzureLoadBalancer` tag for load-balanced workloads).

Associate the NSG with a subnet through the `networkSecurityGroupResourceId` property of the virtual network module's subnets.

## Usage

```bicep
module nsg '../../res/network/network-security-group/main.bicep' = {
  name: 'nsg'
  params: {
    name: 'nsg-web'
    securityRules: [
      {
        name: 'AllowHttpsInbound'
        properties: {
          access: 'Allow'
          direction: 'Inbound'
          priority: 100
          protocol: 'Tcp'
          sourceAddressPrefix: 'Internet'
          sourcePortRange: '*'
          destinationAddressPrefix: 'VirtualNetwork'
          destinationPortRange: '443'
        }
      }
    ]
  }
}
```

## Tests

- [tests/defaults](tests/defaults/main.test.bicep): HTTPS allow rule plus the default deny-all
