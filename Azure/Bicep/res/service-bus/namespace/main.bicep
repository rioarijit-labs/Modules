metadata name = 'Service Bus namespace'
metadata description = 'Service Bus namespace with queues, topics and subscriptions, Entra ID only and private by default (wraps AVM).'

import { roleAssignmentType } from '../../../utl/types/main.bicep'

@export()
@description('A Service Bus queue.')
type queueType = {
  @description('Name of the queue.')
  name: string

  @description('Times a message is delivered before it moves to the dead-letter queue.')
  maxDeliveryCount: int?

  @description('How long a receiver holds a message lock, ISO 8601 duration, e.g. "PT1M". Maximum PT5M.')
  lockDuration: string?

  @description('Default message time to live, ISO 8601 duration, e.g. "P14D".')
  defaultMessageTimeToLive: string?

  @description('Move expired messages to the dead-letter queue instead of dropping them.')
  deadLetteringOnMessageExpiration: bool?

  @description('Require sessions, for ordered processing per session ID.')
  requiresSession: bool?

  @description('Detect and drop duplicate messages by message ID.')
  requiresDuplicateDetection: bool?
}

@export()
@description('A subscription on a Service Bus topic.')
type subscriptionType = {
  @description('Name of the subscription.')
  name: string

  @description('Times a message is delivered before it moves to the dead-letter queue.')
  maxDeliveryCount: int?

  @description('How long a receiver holds a message lock, ISO 8601 duration.')
  lockDuration: string?

  @description('Move expired messages to the dead-letter queue instead of dropping them.')
  deadLetteringOnMessageExpiration: bool?
}

@export()
@description('A Service Bus topic with its subscriptions.')
type topicType = {
  @description('Name of the topic.')
  name: string

  @description('Default message time to live, ISO 8601 duration, e.g. "P14D".')
  defaultMessageTimeToLive: string?

  @description('Detect and drop duplicate messages by message ID.')
  requiresDuplicateDetection: bool?

  @description('Subscriptions on the topic.')
  subscriptions: subscriptionType[]?
}

@description('Name of the namespace. 6-50 characters, letters, numbers and hyphens, starting with a letter. Globally unique.')
@minLength(6)
@maxLength(50)
param name string

@description('Azure region. Defaults to the resource group location.')
param location string = resourceGroup().location

@description('Tags applied to all resources.')
param tags object = {}

@description('Namespace tier. Private endpoints, network rules and zone redundancy require Premium. Basic and Standard are public-only: set publicNetworkAccess to Enabled with them.')
@allowed([
  'Basic'
  'Standard'
  'Premium'
])
param skuName string = 'Premium'

@description('Messaging units for a Premium namespace. Ignored for other tiers.')
@allowed([
  1
  2
  4
  8
  16
])
param premiumCapacity int = 1

@description('Spread the namespace across availability zones. Premium only.')
param zoneRedundant bool = true

@description('Queues to create.')
param queues queueType[] = []

@description('Topics to create.')
param topics topicType[] = []

@description('Public network access. Disabled by default: reach the namespace through a private endpoint (Premium).')
@allowed([
  'Disabled'
  'Enabled'
])
param publicNetworkAccess string = 'Disabled'

@description('Subnet resource ID for the private endpoint. Premium only. Leave empty to skip the private endpoint.')
param privateEndpointSubnetResourceId string = ''

@description('Private DNS zone resource IDs for the endpoint, e.g. privatelink.servicebus.windows.net.')
param privateDnsZoneResourceIds string[] = []

@description('Log Analytics workspace resource ID for diagnostic settings. Leave empty to skip diagnostics.')
param diagnosticsWorkspaceResourceId string = ''

@description('Enable the system-assigned managed identity.')
param enableSystemAssignedIdentity bool = false

@description('RBAC role assignments on the namespace, e.g. "Azure Service Bus Data Sender" or "Azure Service Bus Data Receiver".')
param roleAssignments roleAssignmentType[] = []

var isPremium = skuName == 'Premium'
var dnsZoneGroupConfigs = [
  for zoneResourceId in privateDnsZoneResourceIds: {
    privateDnsZoneResourceId: zoneResourceId
  }
]

module namespace 'br/public:avm/res/service-bus/namespace:0.17.1' = {
  name: '${take(name, 40)}-avm'
  params: {
    name: name
    location: location
    tags: tags
    skuObject: isPremium
      ? {
          name: skuName
          capacity: premiumCapacity
        }
      : {
          name: skuName
        }
    zoneRedundant: isPremium && zoneRedundant
    // Secure defaults
    disableLocalAuth: true
    minimumTlsVersion: '1.2'
    publicNetworkAccess: publicNetworkAccess
    queues: queues
    topics: topics
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

@description('Service Bus endpoint URL, e.g. https://<name>.servicebus.windows.net:443/.')
output serviceBusEndpoint string = namespace.outputs.serviceBusEndpoint
