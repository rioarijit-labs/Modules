metadata name = 'Virtual network'
metadata description = 'Virtual network with subnets, optional NSG association, peerings and diagnostics (wraps AVM).'

@export()
@description('A subnet of the virtual network.')
type subnetType = {
  @description('Name of the subnet.')
  name: string

  @description('Address prefix in CIDR notation, e.g. "10.0.1.0/24". Must fall inside the VNet address space.')
  addressPrefix: string

  @description('Resource ID of the network security group to associate. Recommended for every subnet except those where Azure forbids it (e.g. GatewaySubnet).')
  networkSecurityGroupResourceId: string?

  @description('Service the subnet is delegated to, e.g. "Microsoft.Web/serverFarms" for App Service VNet integration.')
  delegation: string?

  @description('Service endpoints to enable on the subnet, e.g. ["Microsoft.Storage"]. Prefer private endpoints.')
  serviceEndpoints: string[]?

  @description('Whether NSG and route table rules apply to private endpoints in this subnet.')
  privateEndpointNetworkPolicies: ('Disabled' | 'Enabled' | 'NetworkSecurityGroupEnabled' | 'RouteTableEnabled')?

  @description('Resource ID of a route table to associate.')
  routeTableResourceId: string?

  @description('Set to false to disable default outbound internet access for VMs in the subnet.')
  defaultOutboundAccess: bool?
}

@export()
@description('A peering from this virtual network to a remote virtual network.')
type peeringType = {
  @description('Resource ID of the remote virtual network.')
  remoteVirtualNetworkResourceId: string

  @description('Allow traffic forwarded from outside the remote network (needed for hub firewalls / NVAs).')
  allowForwardedTraffic: bool?

  @description('Allow the remote network to use this network gateway.')
  allowGatewayTransit: bool?

  @description('Allow access between the two networks.')
  allowVirtualNetworkAccess: bool?

  @description('Use the remote network gateway.')
  useRemoteGateways: bool?

  @description('Also create the reverse peering from the remote network. The deploying identity needs write access to the remote network.')
  remotePeeringEnabled: bool?
}

@description('Name of the virtual network.')
param name string

@description('Azure region. Defaults to the resource group location.')
param location string = resourceGroup().location

@description('Tags applied to all resources.')
param tags object = {}

@description('Address space in CIDR notation, e.g. ["10.10.0.0/16"].')
@minLength(1)
param addressPrefixes string[]

@description('Subnets to create.')
param subnets subnetType[] = []

@description('Custom DNS server IP addresses. Leave empty to use Azure-provided DNS.')
param dnsServers string[] = []

@description('Peerings to remote virtual networks.')
param peerings peeringType[] = []

@description('Log Analytics workspace resource ID for diagnostic settings. Leave empty to skip diagnostics.')
param diagnosticsWorkspaceResourceId string = ''

module virtualNetwork 'br/public:avm/res/network/virtual-network:0.10.2' = {
  name: '${take(name, 40)}-avm'
  params: {
    name: name
    location: location
    tags: tags
    addressPrefixes: addressPrefixes
    subnets: subnets
    dnsServers: dnsServers
    peerings: peerings
    diagnosticSettings: empty(diagnosticsWorkspaceResourceId)
      ? []
      : [
          { workspaceResourceId: diagnosticsWorkspaceResourceId }
        ]
  }
}

@description('Resource ID of the virtual network.')
output resourceId string = virtualNetwork.outputs.resourceId

@description('Name of the virtual network.')
output name string = virtualNetwork.outputs.name

@description('Names of the subnets, in the order they were declared.')
output subnetNames string[] = virtualNetwork.outputs.subnetNames

@description('Resource IDs of the subnets, in the order they were declared.')
output subnetResourceIds string[] = virtualNetwork.outputs.subnetResourceIds
