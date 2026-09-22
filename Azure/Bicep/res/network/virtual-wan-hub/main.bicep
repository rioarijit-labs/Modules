metadata name = 'Virtual WAN hub'
metadata description = 'A Virtual WAN and one hub inside it, with spoke VNet connections: Microsoft\'s managed alternative to a hand-built hub-and-spoke network (wraps AVM, composing virtual-wan and virtual-hub).'

@export()
@description('A spoke virtual network connected to the hub.')
type spokeConnectionType = {
  @description('Name of the connection.')
  name: string

  @description('Resource ID of the spoke virtual network.')
  remoteVirtualNetworkResourceId: string

  @description('Route the spoke\'s internet-bound traffic through a security provider (e.g. Azure Firewall via routing intent) instead of direct internet egress.')
  enableInternetSecurity: bool?
}

@description('Name of the Virtual WAN resource.')
param name string

@description('Name of the hub inside the Virtual WAN. A Virtual WAN can contain hubs in several regions; this module creates one.')
param hubName string

@description('Azure region for the hub. Defaults to the resource group location. The Virtual WAN resource itself is not regional.')
param location string = resourceGroup().location

@description('Tags applied to all resources.')
param tags object = {}

@description('Address space for the hub itself (not the spokes), e.g. "10.0.0.0/24". At least /24, and it must not overlap any connected spoke.')
param hubAddressPrefix string

@description('Standard unlocks routing intent, third-party NVAs in the hub and most other features. Basic is a smaller, cheaper starting point with major limitations.')
@allowed([
  'Basic'
  'Standard'
])
param sku string = 'Standard'

@description('Allow traffic between spokes connected to different hubs in the same Virtual WAN. Traffic between spokes on the same hub is always allowed.')
param allowBranchToBranchTraffic bool = true

@description('Spoke virtual networks to connect to the hub.')
param spokeConnections spokeConnectionType[] = []

module virtualWan 'br/public:avm/res/network/virtual-wan:0.4.3' = {
  name: '${take(name, 40)}-wan-avm'
  params: {
    name: name
    location: location
    tags: tags
    type: sku
    allowBranchToBranchTraffic: allowBranchToBranchTraffic
  }
}

module virtualHub 'br/public:avm/res/network/virtual-hub:0.5.1' = {
  name: '${take(hubName, 40)}-hub-avm'
  params: {
    name: hubName
    location: location
    tags: tags
    virtualWanResourceId: virtualWan.outputs.resourceId
    addressPrefix: hubAddressPrefix
    sku: sku
    hubVirtualNetworkConnections: [
      for connection in spokeConnections: {
        name: connection.name
        remoteVirtualNetworkResourceId: connection.remoteVirtualNetworkResourceId
        enableInternetSecurity: connection.?enableInternetSecurity ?? true
      }
    ]
  }
}

@description('Resource ID of the Virtual WAN.')
output virtualWanResourceId string = virtualWan.outputs.resourceId

@description('Resource ID of the hub.')
output hubResourceId string = virtualHub.outputs.resourceId

@description('Name of the hub.')
output hubName string = virtualHub.outputs.name
