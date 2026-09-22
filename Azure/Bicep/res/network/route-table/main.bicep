metadata name = 'Route table'
metadata description = 'Route table with user-defined routes, for forcing traffic through a firewall or NVA (wraps AVM).'

import { roleAssignmentType } from '../../../utl/types/main.bicep'

@export()

@description('A user-defined route.')
type routeType = {
  @description('Name of the route.')
  name: string

  @description('CIDR range the route applies to, e.g. "0.0.0.0/0" for all traffic.')
  addressPrefix: string

  @description('Where matching traffic is sent.')
  nextHopType: 'Internet' | 'None' | 'VirtualAppliance' | 'VirtualNetworkGateway' | 'VnetLocal'

  @description('Next hop IP address. Required when nextHopType is VirtualAppliance, e.g. the private IP of an Azure Firewall or NVA.')
  nextHopIpAddress: string?
}

@description('Name of the route table.')
param name string

@description('Azure region. Defaults to the resource group location.')
param location string = resourceGroup().location

@description('Tags applied to the route table.')
param tags object = {}

@description('Routes to create.')
param routes routeType[] = []

@description('Disable BGP route propagation from a virtual network gateway. Set true on a route table that forces traffic through a firewall, so the gateway cannot bypass it.')
param disableBgpRoutePropagation bool = false

@description('RBAC role assignments on the route table, e.g. "Network Contributor" for a platform team.')
param roleAssignments roleAssignmentType[] = []

module routeTable 'br/public:avm/res/network/route-table:0.5.0' = {
  name: '${take(name, 40)}-avm'
  params: {
    name: name
    location: location
    tags: tags
    routes: [
      for route in routes: {
        name: route.name
        properties: {
          addressPrefix: route.addressPrefix
          nextHopType: route.nextHopType
          nextHopIpAddress: route.?nextHopIpAddress
        }
      }
    ]
    disableBgpRoutePropagation: disableBgpRoutePropagation
    roleAssignments: roleAssignments
  }
}

@description('Resource ID of the route table. Associate it with a subnet through the virtual-network module\'s routeTableResourceId.')
output resourceId string = routeTable.outputs.resourceId

@description('Name of the route table.')
output name string = routeTable.outputs.name
