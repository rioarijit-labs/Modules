metadata name = 'Key Vault - defaults'
metadata description = 'Private vault with a private endpoint, diagnostics and a secrets reader role for an app identity.'

// Placeholder IDs: the test validates the module contract, it does not resolve these resources.
module test '../../main.bicep' = {
  name: 'test-key-vault-defaults'
  params: {
    name: 'kv-def-${take(uniqueString(resourceGroup().id), 8)}'
    privateEndpointSubnetResourceId: '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example/providers/Microsoft.Network/virtualNetworks/vnet-example/subnets/snet-private-endpoints'
    privateDnsZoneResourceIds: [
      '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-dns/providers/Microsoft.Network/privateDnsZones/privatelink.vaultcore.azure.net'
    ]
    diagnosticsWorkspaceResourceId: '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example/providers/Microsoft.OperationalInsights/workspaces/log-example'
    roleAssignments: [
      {
        roleDefinitionIdOrName: 'Key Vault Secrets User'
        principalId: '00000000-0000-0000-0000-000000000001'
        principalType: 'ServicePrincipal'
      }
    ]
  }
}
