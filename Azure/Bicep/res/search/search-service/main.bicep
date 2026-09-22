metadata name = 'Azure AI Search'
metadata description = 'Azure AI Search service, Entra ID only and private by default, for vector, hybrid and full-text search (wraps AVM).'

import { roleAssignmentType } from '../../../utl/types/main.bicep'

@description('Name of the search service. 2-60 characters, lowercase letters, numbers and hyphens. Globally unique.')
@minLength(2)
@maxLength(60)
param name string

@description('Azure region. Defaults to the resource group location. Check feature and quota availability per region.')
param location string = resourceGroup().location

@description('Tags applied to all resources.')
param tags object = {}

@description('Service tier. Basic and above support private endpoints and semantic ranking. Free is shared and has no private access.')
@allowed([
  'free'
  'basic'
  'standard'
  'standard2'
  'standard3'
  'storage_optimized_l1'
  'storage_optimized_l2'
])
param skuName string = 'basic'

@description('Number of replicas. Two give read high availability, three give read/write high availability.')
@minValue(1)
@maxValue(12)
param replicaCount int = 1

@description('Number of partitions. More partitions add storage and indexing throughput.')
@allowed([
  1
  2
  3
  4
  6
  12
])
param partitionCount int = 1

@description('Semantic ranker plan. "free" has a monthly query limit.')
@allowed([
  'disabled'
  'free'
  'standard'
])
param semanticSearch string = 'disabled'

@description('Public network access. Disabled by default: reach the service through a private endpoint.')
@allowed([
  'Disabled'
  'Enabled'
])
param publicNetworkAccess string = 'Disabled'

@description('Disable API key authentication so only Microsoft Entra ID is accepted. Callers need roles such as "Search Index Data Reader".')
param disableLocalAuth bool = true

@description('Subnet resource ID for the private endpoint. Leave empty to skip the private endpoint.')
param privateEndpointSubnetResourceId string = ''

@description('Private DNS zone resource IDs for the endpoint, e.g. privatelink.search.windows.net.')
param privateDnsZoneResourceIds string[] = []

@description('Log Analytics workspace resource ID for diagnostic settings. Leave empty to skip diagnostics.')
param diagnosticsWorkspaceResourceId string = ''

@description('Enable the system-assigned managed identity, needed for indexers and integrated vectorization to reach other resources.')
param enableSystemAssignedIdentity bool = true

@description('RBAC role assignments on the service, e.g. "Search Index Data Contributor" for an ingestion identity.')
param roleAssignments roleAssignmentType[] = []

var dnsZoneGroupConfigs = [
  for zoneResourceId in privateDnsZoneResourceIds: {
    privateDnsZoneResourceId: zoneResourceId
  }
]

module searchService 'br/public:avm/res/search/search-service:0.13.0' = {
  name: '${take(name, 40)}-avm'
  params: {
    name: name
    location: location
    tags: tags
    sku: skuName
    replicaCount: replicaCount
    partitionCount: partitionCount
    semanticSearch: semanticSearch
    // Secure defaults
    disableLocalAuth: disableLocalAuth
    publicNetworkAccess: publicNetworkAccess
    privateEndpoints: empty(privateEndpointSubnetResourceId)
      ? []
      : [
          {
            service: 'searchService'
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

@description('Resource ID of the search service.')
output resourceId string = searchService.outputs.resourceId

@description('Name of the search service.')
output name string = searchService.outputs.name

@description('Endpoint URL of the search service.')
output endpoint string = searchService.outputs.endpoint

@description('Principal ID of the system-assigned identity. Empty when not enabled.')
output systemAssignedMIPrincipalId string = searchService.outputs.?systemAssignedMIPrincipalId ?? ''
