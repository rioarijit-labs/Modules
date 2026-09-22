metadata name = 'Redis Cache - defaults'
metadata description = 'Standard cache with a private endpoint and a contributor role assignment.'

// Placeholder IDs: the test validates the module contract, it does not resolve these resources.
module test '../../main.bicep' = {
  name: 'test-redis-defaults'
  params: {
    name: 'redis-defaults-${take(uniqueString(resourceGroup().id), 8)}'
    privateEndpointSubnetResourceId: '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example/providers/Microsoft.Network/virtualNetworks/vnet-example/subnets/snet-private-endpoints'
    privateDnsZoneResourceIds: [
      '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-dns/providers/Microsoft.Network/privateDnsZones/privatelink.redis.cache.windows.net'
    ]
    roleAssignments: [
      {
        roleDefinitionIdOrName: 'Redis Cache Contributor'
        principalId: '00000000-0000-0000-0000-000000000001'
        principalType: 'ServicePrincipal'
      }
    ]
  }
}
