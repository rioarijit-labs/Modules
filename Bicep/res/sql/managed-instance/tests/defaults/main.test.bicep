metadata name = 'SQL Managed Instance - defaults'
metadata description = 'General Purpose 4 vCore instance with an Entra ID admin group and one database.'

// Placeholder IDs: the test validates the module contract, it does not resolve these resources.
module test '../../main.bicep' = {
  name: 'test-sql-managed-instance-defaults'
  params: {
    name: 'sqlmi-defaults-${take(uniqueString(resourceGroup().id), 8)}'
    subnetResourceId: '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example/providers/Microsoft.Network/virtualNetworks/vnet-example/subnets/snet-sqlmi'
    entraAdminLogin: 'sql-admins'
    entraAdminObjectId: '00000000-0000-0000-0000-000000000001'
    databaseNames: ['appdb']
  }
}
