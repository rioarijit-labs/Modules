metadata name = 'App Service - defaults'
metadata description = 'Linux Node app with a managed identity, VNet integration, health check and a private endpoint.'

// Placeholder IDs: the test validates the module contract, it does not resolve these resources.
module test '../../main.bicep' = {
  name: 'test-app-service-defaults'
  params: {
    name: 'app-defaults-${uniqueString(resourceGroup().id)}'
    serverFarmResourceId: '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example/providers/Microsoft.Web/serverfarms/asp-example'
    linuxFxVersion: 'NODE|20-lts'
    healthCheckPath: '/healthz'
    appSettings: {
      WEBSITE_RUN_FROM_PACKAGE: '1'
    }
    virtualNetworkSubnetResourceId: '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example/providers/Microsoft.Network/virtualNetworks/vnet-example/subnets/snet-app-integration'
    privateEndpointSubnetResourceId: '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example/providers/Microsoft.Network/virtualNetworks/vnet-example/subnets/snet-private-endpoints'
  }
}
