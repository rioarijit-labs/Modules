# Azure Firewall

Managed network firewall for a hub virtual network. Wraps `br/public:avm/res/network/azure-firewall:0.11.1`.

## Prerequisites

- The `virtualNetworkResourceId` VNet must contain a subnet named **exactly** `AzureFirewallSubnet`, at least `/26`. Create it with the `virtual-network` module — that subnet name is fixed by Azure, not something you choose.
- `firewallPolicyResourceId` is technically optional in the underlying resource, but a firewall with no policy has no rules and blocks everything. Deploy a [firewall-policy](../firewall-policy) alongside it in practice.
- `skuTier` here must match the tier of the attached firewall policy.

## Public IP

By default the underlying AVM module creates its own public IP for outbound SNAT. Pass `publicIpResourceId` to bring your own instead (for example, one with a reserved static IP that downstream allowlists already reference).

## Routing traffic through it

Deploying the firewall doesn't force any traffic through it. Point a [route-table](../route-table)'s default route (`0.0.0.0/0`, `nextHopType: 'VirtualAppliance'`) at this module's `privateIpAddress` output, and associate that route table with the spoke subnets that should egress through the firewall.

## Usage

```bicep
module firewall '../../res/network/azure-firewall/main.bicep' = {
  name: 'firewall'
  params: {
    name: 'afw-hub-001'
    virtualNetworkResourceId: hubVnet.outputs.resourceId
    firewallPolicyResourceId: firewallPolicy.outputs.resourceId
    diagnosticsWorkspaceResourceId: logs.outputs.resourceId
  }
}

module spokeRouteTable '../../res/network/route-table/main.bicep' = {
  name: 'spoke-route-table'
  params: {
    name: 'rt-spoke'
    routes: [
      {
        name: 'default-via-firewall'
        addressPrefix: '0.0.0.0/0'
        nextHopType: 'VirtualAppliance'
        nextHopIpAddress: firewall.outputs.privateIpAddress
      }
    ]
  }
}
```

## Tests

- [tests/defaults](tests/defaults/main.test.bicep): Standard tier in a hub VNet with a policy and diagnostics
