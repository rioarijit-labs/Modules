metadata name = 'Event Hubs namespace'
metadata description = 'Event Hubs namespace with event hubs and consumer groups, Entra ID only and private by default (wraps AVM).'

import { roleAssignmentType } from '../../../utl/types/main.bicep'

@export()
@description('A consumer group on an event hub.')
type consumerGroupType = {
  @description('Name of the consumer group.')
  name: string
}

@export()
@description('An event hub.')
type eventHubType = {
  @description('Name of the event hub.')
  name: string

  @description('Number of partitions. Cannot be changed after creation on Basic and Standard. Bounds the read parallelism.')
  @minValue(1)
  @maxValue(32)
  partitionCount: int?

  @description('Days events are retained. Standard allows up to 7.')
  @minValue(1)
  @maxValue(90)
  messageRetentionInDays: int?

  @description('Consumer groups on the event hub. $Default always exists.')
  consumergroups: consumerGroupType[]?
}

@description('Name of the namespace. 6-50 characters, letters, numbers and hyphens, starting with a letter. Globally unique.')
@minLength(6)
@maxLength(50)
param name string

@description('Azure region. Defaults to the resource group location.')
param location string = resourceGroup().location

@description('Tags applied to all resources.')
param tags object = {}

@description('Namespace tier. Private endpoints need Standard or Premium. Basic is public-only: set publicNetworkAccess to Enabled with it.')
@allowed([
  'Basic'
  'Standard'
  'Premium'
])
param skuName string = 'Standard'

@description('Throughput units (Basic and Standard) or processing units (Premium).')
@minValue(1)
@maxValue(20)
param skuCapacity int = 1

@description('Spread the namespace across availability zones.')
param zoneRedundant bool = true

@description('Automatically scale throughput units up to maximumThroughputUnits. Standard only.')
param isAutoInflateEnabled bool = false

@description('Upper limit for auto-inflate. Only used when isAutoInflateEnabled is true.')
@minValue(0)
@maxValue(20)
param maximumThroughputUnits int = 0

@description('Event hubs to create.')
param eventHubs eventHubType[] = []

@description('Public network access. Disabled by default: reach the namespace through a private endpoint (Standard or Premium).')
@allowed([
  'Disabled'
  'Enabled'
])
param publicNetworkAccess string = 'Disabled'

@description('Subnet resource ID for the private endpoint. Leave empty to skip the private endpoint.')
param privateEndpointSubnetResourceId string = ''

@description('Private DNS zone resource IDs for the endpoint, e.g. privatelink.servicebus.windows.net.')
param privateDnsZoneResourceIds string[] = []

@description('Log Analytics workspace resource ID for diagnostic settings. Leave empty to skip diagnostics.')
param diagnosticsWorkspaceResourceId string = ''

@description('Enable the system-assigned managed identity.')
param enableSystemAssignedIdentity bool = false

@description('RBAC role assignments on the namespace, e.g. "Azure Event Hubs Data Sender" or "Azure Event Hubs Data Receiver".')
param roleAssignments roleAssignmentType[] = []

var dnsZoneGroupConfigs = [
  for zoneResourceId in privateDnsZoneResourceIds: {
    privateDnsZoneResourceId: zoneResourceId
  }
]

module namespace 'br/public:avm/res/event-hub/namespace:0.15.1' = {
  name: '${take(name, 40)}-avm'
  params: {
    name: name
    location: location
    tags: tags
    skuName: skuName
    skuCapacity: skuCapacity
    zoneRedundant: zoneRedundant
    isAutoInflateEnabled: isAutoInflateEnabled
    maximumThroughputUnits: maximumThroughputUnits
    // Secure defaults
    disableLocalAuth: true
    minimumTlsVersion: '1.2'
    publicNetworkAccess: publicNetworkAccess
    eventhubs: eventHubs
    privateEndpoints: empty(privateEndpointSubnetResourceId)
      ? []
      : [
          {
            service: 'namespace'
            subnetResourceId: privateEndpointSubnetResourceId
            tags: tags
            privateDnsZoneGroup: empty(dnsZoneGroupConfigs)
              ? null
              : {
                  privateDnsZoneGroupConfigs: dnsZoneGroupConfigs
                }
          }
        ]
    diagnosticSettings: empty(diagnosticsWorkspaceResourceId)
      ? []
      : [
          { workspaceResourceId: diagnosticsWorkspaceResourceId }
        ]
    managedIdentities: {
      systemAssigned: enableSystemAssignedIdentity
    }
    roleAssignments: roleAssignments
  }
}

@description('Resource ID of the namespace.')
output resourceId string = namespace.outputs.resourceId

@description('Name of the namespace.')
output name string = namespace.outputs.name
