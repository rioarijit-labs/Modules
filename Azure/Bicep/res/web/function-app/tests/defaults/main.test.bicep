metadata name = 'Azure Functions - defaults'
metadata description = 'Node function app on a Consumption plan with keyless storage access and VNet integration.'

// Placeholder IDs: the test validates the module contract, it does not resolve these resources.
module test '../../main.bicep' = {
  name: 'test-function-app-defaults'
  params: {
    name: 'func-defaults-${take(uniqueString(resourceGroup().id), 8)}'
    serverFarmResourceId: '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example/providers/Microsoft.Web/serverfarms/asp-consumption-example'
    workerRuntime: 'node'
    runtimeVersion: '20'
    storageAccountName: 'stfuncexample001'
    virtualNetworkSubnetResourceId: '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example/providers/Microsoft.Network/virtualNetworks/vnet-example/subnets/snet-app-integration'
    privateEndpointSubnetResourceId: '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example/providers/Microsoft.Network/virtualNetworks/vnet-example/subnets/snet-private-endpoints'
  }
}
