metadata name = 'Container instance - defaults'
metadata description = 'A one-off job container with plain and secret environment variables, placed in a subnet.'

// Placeholder IDs: the test validates the module contract, it does not resolve these resources.
@secure()
param apiKey string = newGuid()

module test '../../main.bicep' = {
  name: 'test-container-group-defaults'
  params: {
    name: 'aci-defaults'
    subnetResourceId: '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example/providers/Microsoft.Network/virtualNetworks/vnet-example/subnets/snet-workload'
    restartPolicy: 'Never'
    containers: [
      {
        name: 'job'
        image: 'mcr.microsoft.com/azure-cli:latest'
        cpuCores: 1
        memoryInGB: 2
        command: ['az', 'account', 'show']
        environmentVariables: {
          LOG_LEVEL: 'info'
        }
        secureEnvironmentVariables: {
          API_KEY: apiKey
        }
      }
    ]
  }
}
