metadata name = 'Redis Cache'
metadata description = 'Azure Cache for Redis, Entra ID only and private by default (wraps AVM).'

import { roleAssignmentType } from '../../../utl/types/main.bicep'

@description('Name of the cache. 1-63 characters, letters, numbers and hyphens.')
@minLength(1)
@maxLength(63)
param name string

@description('Azure region. Defaults to the resource group location.')
param location string = resourceGroup().location

@description('Tags applied to all resources.')
param tags object = {}

@description('Tier. Basic has no SLA and no replication. Standard adds a replica for HA. Premium adds clustering, persistence, VNet injection and zone redundancy.')
@allowed([
  'Basic'
  'Standard'
  'Premium'
])
param skuName string = 'Standard'

@description('Size within the tier: 0-6 for Basic/Standard (250 MB to 53 GB), 1-5 for Premium (6 GB to 120 GB).')
@minValue(0)
@maxValue(6)
param capacity int = 1

@description('Number of shards for clustering. Premium only, and only meaningful above 1.')
param shardCount int?

@description('Public network access. Disabled by default: reach the cache through a private endpoint (any tier) or VNet injection (Premium).')
@allowed([
  'Disabled'
  'Enabled'
])
param publicNetworkAccess string = 'Disabled'

@description('Disable access-key authentication so only Microsoft Entra ID is accepted. Grant access with roleAssignments, e.g. "Redis Cache Contributor" for management, or a Redis-native data access policy for data-plane access.')
param disableAccessKeyAuthentication bool = true

@description('Subnet resource ID for the private endpoint. Leave empty to skip the private endpoint.')
param privateEndpointSubnetResourceId string = ''

@description('Private DNS zone resource IDs for the endpoint, e.g. privatelink.redis.cache.windows.net.')
param privateDnsZoneResourceIds string[] = []

@description('Log Analytics workspace resource ID for diagnostic settings. Leave empty to skip diagnostics.')
param diagnosticsWorkspaceResourceId string = ''

@description('Enable the system-assigned managed identity.')
param enableSystemAssignedIdentity bool = false

@description('RBAC role assignments on the cache resource (management plane), e.g. "Redis Cache Contributor".')
param roleAssignments roleAssignmentType[] = []

var dnsZoneGroupConfigs = [
  for zoneResourceId in privateDnsZoneResourceIds: {
    privateDnsZoneResourceId: zoneResourceId
  }
]

module redisCache 'br/public:avm/res/cache/redis:0.18.0' = {
  name: '${take(name, 40)}-avm'
  params: {
    name: name
    location: location
    tags: tags
    skuName: skuName
    capacity: capacity
    shardCount: skuName == 'Premium' ? shardCount : null
    // Secure defaults: Entra ID only, TLS 1.2, private access
    minimumTlsVersion: '1.2'
    enableNonSslPort: false
    disableAccessKeyAuthentication: disableAccessKeyAuthentication
    publicNetworkAccess: publicNetworkAccess
    privateEndpoints: empty(privateEndpointSubnetResourceId)
      ? []
      : [
          {
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

@description('Resource ID of the cache.')
output resourceId string = redisCache.outputs.resourceId

@description('Name of the cache.')
output name string = redisCache.outputs.name

@description('Host name to connect to, e.g. <name>.redis.cache.windows.net.')
output hostName string = redisCache.outputs.hostName

@description('SSL port.')
output sslPort int = redisCache.outputs.sslPort
