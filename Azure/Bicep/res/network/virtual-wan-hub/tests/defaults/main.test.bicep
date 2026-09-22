metadata name = 'Virtual WAN hub - defaults'
metadata description = 'Standard WAN and hub with one spoke VNet connection.'

// Placeholder IDs: the test validates the module contract, it does not resolve these resources.
module test '../../main.bicep' = {
  name: 'test-virtual-wan-hub-defaults'
  params: {
    name: 'vwan-example'
    hubName: 'hub-westeurope'
    hubAddressPrefix: '10.0.0.0/24'
    spokeConnections: [
      {
        name: 'spoke-workload'
        remoteVirtualNetworkResourceId: '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example/providers/Microsoft.Network/virtualNetworks/vnet-spoke'
      }
    ]
  }
}
