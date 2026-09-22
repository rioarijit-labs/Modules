metadata name = 'Storage account'
metadata description = 'Secure-by-default storage account (wraps AVM) with optional blob containers, private endpoints and diagnostics.'

import { roleAssignmentType } from '../../../utl/types/main.bicep'

@description('Name of the storage account. 3-24 characters, lowercase letters and numbers only.')
@minLength(3)
@maxLength(24)
param name string

@description('Azure region. Defaults to the resource group location.')
param location string = resourceGroup().location

@description('Tags applied to all resources.')
param tags object = {}

@description('Storage account SKU. Defaults to zone-redundant storage.')
@allowed([
  'Standard_LRS'
  'Standard_ZRS'
  'Standard_GRS'
  'Standard_GZRS'
  'Standard_RAGRS'
  'Standard_RAGZRS'
  'Premium_LRS'
  'Premium_ZRS'
])
param skuName string = 'Standard_ZRS'

@description('Storage account kind.')
@allowed([
  'StorageV2'
  'BlobStorage'
  'BlockBlobStorage'
  'FileStorage'
])
param kind string = 'StorageV2'

@description('Enable hierarchical namespace (Data Lake Storage Gen2).')
param enableHierarchicalNamespace bool = false

@description('Names of private blob containers to create.')
param containerNames string[] = []

@description('Days to retain deleted blobs and containers (soft delete).')
@minValue(1)
@maxValue(365)
param softDeleteRetentionDays int = 7

@description('Public network access. Disabled by default: reach the data plane through a private endpoint.')
@allowed([
  'Disabled'
  'Enabled'
  'SecuredByPerimeter'
])
param publicNetworkAccess string = 'Disabled'

@description('Subnet resource ID for private endpoints. Leave empty to skip private endpoints.')
param privateEndpointSubnetResourceId string = ''

@description('Storage services to expose through private endpoints. Only used when privateEndpointSubnetResourceId is set.')
param privateEndpointServices ('blob' | 'file' | 'queue' | 'table' | 'dfs' | 'web')[] = ['blob']

@description('Private DNS zone resource IDs keyed by service, e.g. { blob: "<privatelink.blob.core.windows.net zone ID>" }. Services without an entry get no DNS zone group.')
param privateDnsZoneResourceIds object = {}

@description('Log Analytics workspace resource ID for diagnostic settings. Leave empty to skip diagnostics.')
param diagnosticsWorkspaceResourceId string = ''

@description('Enable the system-assigned managed identity.')
param enableSystemAssignedIdentity bool = false

@description('Resource IDs of user-assigned managed identities to attach.')
param userAssignedIdentityResourceIds string[] = []

@description('RBAC role assignments on the storage account.')
param roleAssignments roleAssignmentType[] = []

var privateEndpointServicesToDeploy = empty(privateEndpointSubnetResourceId) ? [] : privateEndpointServices

module storageAccount 'br/public:avm/res/storage/storage-account:0.33.1' = {
  name: '${take(name, 40)}-avm'
  params: {
    name: name
    location: location
    tags: tags
    kind: kind
    skuName: skuName
    enableHierarchicalNamespace: enableHierarchicalNamespace
    // Secure defaults
    allowBlobPublicAccess: false
    allowSharedKeyAccess: false
    defaultToOAuthAuthentication: true
    minimumTlsVersion: 'TLS1_2'
    supportsHttpsTrafficOnly: true
    publicNetworkAccess: publicNetworkAccess
    networkAcls: {
      defaultAction: 'Deny'
      bypass: 'AzureServices'
    }
    blobServices: {
      deleteRetentionPolicyEnabled: true
      deleteRetentionPolicyDays: softDeleteRetentionDays
      containerDeleteRetentionPolicyEnabled: true
      containerDeleteRetentionPolicyDays: softDeleteRetentionDays
      containers: [
        for containerName in containerNames: {
          name: containerName
          publicAccess: 'None'
        }
      ]
    }
    privateEndpoints: [
      for service in privateEndpointServicesToDeploy: {
        service: service
        subnetResourceId: privateEndpointSubnetResourceId
        tags: tags
        privateDnsZoneGroup: contains(privateDnsZoneResourceIds, service)
          ? {
              privateDnsZoneGroupConfigs: [
                { privateDnsZoneResourceId: privateDnsZoneResourceIds[service] }
              ]
            }
          : null
      }
    ]
    diagnosticSettings: empty(diagnosticsWorkspaceResourceId)
      ? []
      : [
          { workspaceResourceId: diagnosticsWorkspaceResourceId }
        ]
    managedIdentities: {
      systemAssigned: enableSystemAssignedIdentity
      userAssignedResourceIds: userAssignedIdentityResourceIds
    }
    roleAssignments: roleAssignments
  }
}

@description('Resource ID of the storage account.')
output resourceId string = storageAccount.outputs.resourceId

@description('Name of the storage account.')
output name string = storageAccount.outputs.name

@description('Primary blob endpoint URL.')
output primaryBlobEndpoint string = storageAccount.outputs.primaryBlobEndpoint

@description('Principal ID of the system-assigned identity. Empty when not enabled.')
output systemAssignedMIPrincipalId string = storageAccount.outputs.?systemAssignedMIPrincipalId ?? ''
