metadata name = 'Private endpoint - defaults'
metadata description = 'Private endpoint to the blob service of a storage account, with a private DNS zone group.'

// Placeholder IDs: the test validates the module contract, it does not resolve these resources.
module test '../../main.bicep' = {
  name: 'test-private-endpoint-defaults'
  params: {
    name: 'pe-defaults'
    subnetResourceId: '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example/providers/Microsoft.Network/virtualNetworks/vnet-example/subnets/snet-private-endpoints'
    privateLinkServiceResourceId: '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example/providers/Microsoft.Storage/storageAccounts/stexample'
    groupIds: ['blob']
    privateDnsZoneResourceIds: [
      '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-dns/providers/Microsoft.Network/privateDnsZones/privatelink.blob.${environment().suffixes.storage}'
    ]
  }
}
