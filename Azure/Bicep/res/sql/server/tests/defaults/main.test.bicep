metadata name = 'SQL Server - defaults'
metadata description = 'Entra ID only server with a General Purpose serverless database and a private endpoint.'

// Placeholder IDs: the test validates the module contract, it does not resolve these resources.
module test '../../main.bicep' = {
  name: 'test-sql-server-defaults'
  params: {
    name: 'sql-defaults-${take(uniqueString(resourceGroup().id), 8)}'
    entraAdminLogin: 'sql-admins'
    entraAdminObjectId: '00000000-0000-0000-0000-000000000001'
    databases: [
      {
        name: 'appdb'
        skuName: 'GP_S_Gen5_2'
        skuTier: 'GeneralPurpose'
      }
    ]
    privateEndpointSubnetResourceId: '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example/providers/Microsoft.Network/virtualNetworks/vnet-example/subnets/snet-private-endpoints'
    privateDnsZoneResourceIds: [
      '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-dns/providers/Microsoft.Network/privateDnsZones/privatelink${environment().suffixes.sqlServerHostname}'
    ]
    diagnosticsWorkspaceResourceId: '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example/providers/Microsoft.OperationalInsights/workspaces/log-example'
  }
}
