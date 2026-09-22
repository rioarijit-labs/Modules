metadata name = 'Private DNS zone'
metadata description = 'Private DNS zone linked to one or more virtual networks, used to resolve private endpoint names (wraps AVM).'

@description('Name of the zone, e.g. "privatelink.blob.core.windows.net". Use the exact privatelink name for the service, it is not free-form.')
param name string

@description('Tags applied to the zone and its links.')
param tags object = {}

@description('Resource IDs of the virtual networks to link to the zone. Each network resolves the zone through Azure DNS.')
param virtualNetworkResourceIds string[] = []

@description('Enable auto-registration of VM records from the linked networks. Leave false for private endpoint zones.')
param registrationEnabled bool = false

var virtualNetworkLinks = [
  for virtualNetworkResourceId in virtualNetworkResourceIds: {
    name: 'link-${last(split(virtualNetworkResourceId, '/'))}'
    virtualNetworkResourceId: virtualNetworkResourceId
    registrationEnabled: registrationEnabled
    tags: tags
  }
]

module privateDnsZone 'br/public:avm/res/network/private-dns-zone:0.8.1' = {
  name: '${take(replace(name, '.', '-'), 40)}-avm'
  params: {
    name: name
    tags: tags
    virtualNetworkLinks: virtualNetworkLinks
  }
}

@description('Resource ID of the private DNS zone.')
output resourceId string = privateDnsZone.outputs.resourceId

@description('Name of the private DNS zone.')
output name string = privateDnsZone.outputs.name
