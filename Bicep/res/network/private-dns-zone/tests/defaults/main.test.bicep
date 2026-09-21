metadata name = 'Private DNS zone - defaults'
metadata description = 'Blob private endpoint zone linked to a hub and a spoke network.'

// Placeholder IDs: the test validates the module contract, it does not resolve these resources.
module test '../../main.bicep' = {
  name: 'test-private-dns-zone-defaults'
  params: {
    name: 'privatelink.blob.${environment().suffixes.storage}'
    virtualNetworkResourceIds: [
      '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-hub/providers/Microsoft.Network/virtualNetworks/vnet-hub'
      '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-spoke/providers/Microsoft.Network/virtualNetworks/vnet-spoke'
    ]
  }
}
