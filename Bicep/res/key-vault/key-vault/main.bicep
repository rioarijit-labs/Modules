metadata name = 'Key Vault'
metadata description = 'Secure-by-default Key Vault: RBAC authorization, purge protection, private endpoint and diagnostics (wraps AVM).'

import { roleAssignmentType } from '../../../utl/types/main.bicep'

@description('Name of the vault. 3-24 characters, letters, numbers and hyphens, starting with a letter. Globally unique.')
@minLength(3)
@maxLength(24)
param name string

@description('Azure region. Defaults to the resource group location.')
param location string = resourceGroup().location

@description('Tags applied to all resources.')
param tags object = {}

@description('Vault SKU. Premium adds HSM-backed keys.')
@allowed([
  'standard'
  'premium'
])
param skuName string = 'standard'

@description('Days deleted vault objects are retained before permanent deletion.')
@minValue(7)
@maxValue(90)
param softDeleteRetentionInDays int = 90

@description('Block permanent deletion until the retention period ends. This cannot be turned off once enabled, and the vault name stays reserved while a deleted vault is retained.')
param enablePurgeProtection bool = true

@description('Public network access. Disabled by default: reach the vault through a private endpoint.')
@allowed([
  'Disabled'
  'Enabled'
])
param publicNetworkAccess string = 'Disabled'

@description('Subnet resource ID for the private endpoint. Leave empty to skip the private endpoint.')
param privateEndpointSubnetResourceId string = ''

@description('Private DNS zone resource IDs for the endpoint, e.g. privatelink.vaultcore.azure.net.')
param privateDnsZoneResourceIds string[] = []

@description('Log Analytics workspace resource ID for diagnostic settings. Leave empty to skip diagnostics.')
param diagnosticsWorkspaceResourceId string = ''

@description('RBAC role assignments on the vault, e.g. "Key Vault Secrets User" for an app identity. The vault uses Azure RBAC, not access policies.')
param roleAssignments roleAssignmentType[] = []

var dnsZoneGroupConfigs = [
  for zoneResourceId in privateDnsZoneResourceIds: {
    privateDnsZoneResourceId: zoneResourceId
  }
]

module keyVault 'br/public:avm/res/key-vault/vault:0.14.2' = {
  name: '${take(name, 40)}-avm'
  params: {
    name: name
    location: location
    tags: tags
    sku: skuName
    // Secure defaults
    enableRbacAuthorization: true
    enableSoftDelete: true
    softDeleteRetentionInDays: softDeleteRetentionInDays
    enablePurgeProtection: enablePurgeProtection
    publicNetworkAccess: publicNetworkAccess
    networkAcls: {
      defaultAction: 'Deny'
      bypass: 'AzureServices'
    }
    privateEndpoints: empty(privateEndpointSubnetResourceId)
      ? []
      : [
          {
            service: 'vault'
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
    roleAssignments: roleAssignments
  }
}

@description('Resource ID of the vault.')
output resourceId string = keyVault.outputs.resourceId

@description('Name of the vault.')
output name string = keyVault.outputs.name

@description('URI of the vault, e.g. for Key Vault references.')
output uri string = keyVault.outputs.uri
