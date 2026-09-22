metadata name = 'Cosmos DB account - private, multi-region'
metadata description = 'Serverless account with a second read region, a private endpoint and diagnostics.'

// Placeholder IDs: the test validates the module contract, it does not resolve these resources.
module test '../../main.bicep' = {
  name: 'test-cosmos-db-account-private'
  params: {
    name: 'cosmos-private-${take(uniqueString(resourceGroup().id), 8)}'
    capacityMode: 'Serverless'
    additionalLocations: ['westus2']
    enableAutomaticFailover: true
    sqlDatabases: [
      {
        name: 'sessions'
        containers: [
          {
            name: 'agent-sessions'
            partitionKeyPaths: ['/sessionId']
          }
        ]
      }
    ]
    privateEndpointSubnetResourceId: '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example/providers/Microsoft.Network/virtualNetworks/vnet-example/subnets/snet-private-endpoints'
    privateDnsZoneResourceIds: [
      '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-dns/providers/Microsoft.Network/privateDnsZones/privatelink.documents.azure.com'
    ]
    diagnosticsWorkspaceResourceId: '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example/providers/Microsoft.OperationalInsights/workspaces/log-example'
  }
}
