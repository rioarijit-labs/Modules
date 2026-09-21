# Virtual network

Virtual network with typed subnets and peerings. Wraps `br/public:avm/res/network/virtual-network:0.10.2`.

## Notes

- `subnetResourceIds` and `subnetNames` outputs follow the order of the `subnets` parameter.
- Associate NSGs per subnet with `networkSecurityGroupResourceId`. Do not associate one with `GatewaySubnet`.
- Subnets that host App Service VNet integration need `delegation: 'Microsoft.Web/serverFarms'`.
- Peerings: set `remotePeeringEnabled: true` to create the reverse peering as well. The deploying identity needs write access on the remote network.

## Usage

```bicep
module vnet '../../res/network/virtual-network/main.bicep' = {
  name: 'vnet'
  params: {
    name: 'vnet-spoke'
    addressPrefixes: ['10.10.0.0/16']
    subnets: [
      {
        name: 'snet-workload'
        addressPrefix: '10.10.0.0/24'
        networkSecurityGroupResourceId: nsg.outputs.resourceId
      }
    ]
  }
}
```

## Tests

- [tests/defaults](tests/defaults/main.test.bicep): workload, private endpoint and delegated integration subnets
