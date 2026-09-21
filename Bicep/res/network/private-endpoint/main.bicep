metadata name = 'Private endpoint'
metadata description = 'Private endpoint to any Azure PaaS resource, with optional private DNS zone group (wraps AVM).'

@description('Name of the private endpoint.')
param name string

@description('Azure region. Must match the region of the virtual network. Defaults to the resource group location.')
param location string = resourceGroup().location

@description('Tags applied to the private endpoint.')
param tags object = {}

@description('Resource ID of the subnet the private endpoint network interface is placed in.')
param subnetResourceId string

@description('Resource ID of the target PaaS resource (storage account, Key Vault, web app, ...).')
param privateLinkServiceResourceId string

@description('Sub-resource (group ID) to connect to, e.g. ["blob"], ["vault"], ["sites"], ["account"].')
@minLength(1)
param groupIds string[]

@description('Private DNS zone resource IDs to register the endpoint in, e.g. privatelink.blob.core.windows.net. Leave empty to manage DNS elsewhere.')
param privateDnsZoneResourceIds string[] = []

var dnsZoneGroupConfigs = [
  for zoneResourceId in privateDnsZoneResourceIds: {
    privateDnsZoneResourceId: zoneResourceId
  }
]

module privateEndpoint 'br/public:avm/res/network/private-endpoint:0.12.1' = {
  name: '${take(name, 40)}-avm'
  params: {
    name: name
    location: location
    tags: tags
    subnetResourceId: subnetResourceId
    privateLinkServiceConnections: [
      {
        name: name
        properties: {
          privateLinkServiceId: privateLinkServiceResourceId
          groupIds: groupIds
        }
      }
    ]
    privateDnsZoneGroup: empty(dnsZoneGroupConfigs)
      ? null
      : {
          privateDnsZoneGroupConfigs: dnsZoneGroupConfigs
        }
  }
}

@description('Resource ID of the private endpoint.')
output resourceId string = privateEndpoint.outputs.resourceId

@description('Name of the private endpoint.')
output name string = privateEndpoint.outputs.name

@description('Resource IDs of the network interfaces created for the private endpoint.')
output networkInterfaceResourceIds string[] = privateEndpoint.outputs.networkInterfaceResourceIds
