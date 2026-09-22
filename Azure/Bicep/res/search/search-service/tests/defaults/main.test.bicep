metadata name = 'Azure AI Search - defaults'
metadata description = 'Basic service with a private endpoint and index roles for an ingestion identity and a query identity.'

// Placeholder IDs: the test validates the module contract, it does not resolve these resources.
module test '../../main.bicep' = {
  name: 'test-search-service-defaults'
  params: {
    name: 'srch-defaults-${take(uniqueString(resourceGroup().id), 8)}'
    privateEndpointSubnetResourceId: '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example/providers/Microsoft.Network/virtualNetworks/vnet-example/subnets/snet-private-endpoints'
    privateDnsZoneResourceIds: [
      '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-dns/providers/Microsoft.Network/privateDnsZones/privatelink.search.windows.net'
    ]
    roleAssignments: [
      {
        roleDefinitionIdOrName: 'Search Index Data Contributor'
        principalId: '00000000-0000-0000-0000-000000000001'
        principalType: 'ServicePrincipal'
      }
      {
        roleDefinitionIdOrName: 'Search Index Data Reader'
        principalId: '00000000-0000-0000-0000-000000000002'
        principalType: 'ServicePrincipal'
      }
    ]
  }
}
