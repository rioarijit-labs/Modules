metadata name = 'Virtual network - defaults'
metadata description = 'Spoke network with a workload subnet, a private endpoint subnet and an App Service integration subnet.'

module test '../../main.bicep' = {
  name: 'test-vnet-defaults'
  params: {
    name: 'vnet-defaults'
    addressPrefixes: ['10.10.0.0/16']
    subnets: [
      {
        name: 'snet-workload'
        addressPrefix: '10.10.0.0/24'
      }
      {
        name: 'snet-private-endpoints'
        addressPrefix: '10.10.1.0/24'
        privateEndpointNetworkPolicies: 'Enabled'
      }
      {
        name: 'snet-app-integration'
        addressPrefix: '10.10.2.0/24'
        delegation: 'Microsoft.Web/serverFarms'
      }
    ]
  }
}
