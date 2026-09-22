metadata name = 'Static Web App - private, with source control'
metadata description = 'Internal-only app reachable through a private endpoint, deployed from a GitHub repository.'

// Placeholder IDs: the test validates the module contract, it does not resolve these resources.
@secure()
param repositoryToken string = newGuid()

module test '../../main.bicep' = {
  name: 'test-static-site-private'
  params: {
    name: 'swa-private-${take(uniqueString(resourceGroup().id), 8)}'
    publicNetworkAccess: 'Disabled'
    privateEndpointSubnetResourceId: '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example/providers/Microsoft.Network/virtualNetworks/vnet-example/subnets/snet-private-endpoints'
    privateDnsZoneResourceIds: [
      '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-dns/providers/Microsoft.Network/privateDnsZones/privatelink.azurestaticapps.net'
    ]
    repository: {
      provider: 'GitHub'
      repositoryUrl: 'https://github.com/example/docs-site'
      branch: 'main'
      repositoryToken: repositoryToken
      appLocation: '/'
      outputLocation: 'dist'
    }
  }
}
