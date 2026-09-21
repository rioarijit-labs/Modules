metadata name = 'Virtual machine - Windows'
metadata description = 'Windows Server VM with a generated test password, Azure Monitor Agent and a data collection rule.'

// The password is generated for the test only. Real deployments read it from Key Vault.
@secure()
param adminPassword string = newGuid()

// Placeholder IDs: the test validates the module contract, it does not resolve these resources.
module test '../../main.bicep' = {
  name: 'test-virtual-machine-windows'
  params: {
    name: 'vm-windows-test'
    osType: 'Windows'
    subnetResourceId: '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example/providers/Microsoft.Network/virtualNetworks/vnet-example/subnets/snet-workload'
    adminPassword: adminPassword
    dataCollectionRuleResourceIds: [
      '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example/providers/Microsoft.Insights/dataCollectionRules/dcr-example'
    ]
  }
}
