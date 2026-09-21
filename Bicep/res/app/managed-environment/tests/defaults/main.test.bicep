metadata name = 'Container Apps environment - defaults'
metadata description = 'Internal environment in a delegated subnet with logs sent to Log Analytics.'

// Placeholder IDs: the test validates the module contract, it does not resolve these resources.
module test '../../main.bicep' = {
  name: 'test-managed-environment-defaults'
  params: {
    name: 'cae-defaults'
    infrastructureSubnetResourceId: '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example/providers/Microsoft.Network/virtualNetworks/vnet-example/subnets/snet-container-apps'
    diagnosticsWorkspaceResourceId: '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example/providers/Microsoft.OperationalInsights/workspaces/log-example'
  }
}
