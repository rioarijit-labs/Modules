metadata name = 'Container registry - defaults'
metadata description = 'Premium registry with a private endpoint and AcrPull for a workload identity.'

// Placeholder IDs: the test validates the module contract, it does not resolve these resources.
module test '../../main.bicep' = {
  name: 'test-container-registry-defaults'
  params: {
    name: 'acrdefaults${take(uniqueString(resourceGroup().id), 8)}'
    privateEndpointSubnetResourceId: '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example/providers/Microsoft.Network/virtualNetworks/vnet-example/subnets/snet-private-endpoints'
    privateDnsZoneResourceIds: [
      '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-dns/providers/Microsoft.Network/privateDnsZones/privatelink.azurecr.io'
    ]
    roleAssignments: [
      {
        roleDefinitionIdOrName: 'AcrPull'
        principalId: '00000000-0000-0000-0000-000000000001'
        principalType: 'ServicePrincipal'
      }
    ]
  }
}
