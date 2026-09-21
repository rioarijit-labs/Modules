metadata name = 'Storage account - private'
metadata description = 'Data lake with containers, blob and dfs private endpoints, DNS zone groups and diagnostics.'

// Placeholder IDs: the test validates the module contract, it does not resolve these resources.
var subnetResourceId = '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example/providers/Microsoft.Network/virtualNetworks/vnet-example/subnets/snet-private-endpoints'
var privateDnsZoneRoot = '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-dns/providers/Microsoft.Network/privateDnsZones'

module test '../../main.bicep' = {
  name: 'test-storage-private'
  params: {
    name: 'stprivate${uniqueString(resourceGroup().id)}'
    tags: { environment: 'test' }
    enableHierarchicalNamespace: true
    containerNames: ['raw', 'curated']
    privateEndpointSubnetResourceId: subnetResourceId
    privateEndpointServices: ['blob', 'dfs']
    privateDnsZoneResourceIds: {
      blob: '${privateDnsZoneRoot}/privatelink.blob.${environment().suffixes.storage}'
      dfs: '${privateDnsZoneRoot}/privatelink.dfs.${environment().suffixes.storage}'
    }
    diagnosticsWorkspaceResourceId: '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example/providers/Microsoft.OperationalInsights/workspaces/log-example'
  }
}
