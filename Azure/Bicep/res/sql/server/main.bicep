metadata name = 'SQL Server'
metadata description = 'Azure SQL logical server with databases, Entra ID only and private by default (wraps AVM).'

import { roleAssignmentType } from '../../../utl/types/main.bicep'

@export()
@description('A database on the server.')
type databaseType = {
  @description('Name of the database.')
  name: string

  @description('SKU name, e.g. "GP_S_Gen5_2" (General Purpose serverless, 2 vCores), "S0" (Standard DTU-based) or "HS_Gen5_4" (Hyperscale). See the Azure SQL pricing page for valid combinations.')
  skuName: string

  @description('SKU tier matching skuName, e.g. "GeneralPurpose", "Standard", "Hyperscale".')
  skuTier: string

  @description('Maximum database size in bytes. Omit to use the SKU default.')
  maxSizeBytes: int?

  @description('Spread the database across availability zones. Not available for every SKU or region.')
  zoneRedundant: bool?

  @description('Availability zone: 1, 2 or 3. Use -1 (the default) to let Azure place it automatically.')
  availabilityZone: int?
}

@description('Name of the logical server. 1-63 characters, lowercase letters, numbers and hyphens. Globally unique.')
@minLength(1)
@maxLength(63)
param name string

@description('Azure region. Defaults to the resource group location.')
param location string = resourceGroup().location

@description('Tags applied to all resources.')
param tags object = {}

@description('Display name of the Microsoft Entra administrator (a group is recommended), e.g. "sql-admins".')
param entraAdminLogin string

@description('Object ID of the Microsoft Entra administrator.')
param entraAdminObjectId string

@description('Type of the Microsoft Entra administrator.')
@allowed([
  'Group'
  'User'
  'Application'
])
param entraAdminPrincipalType string = 'Group'

@description('Databases to create on the server.')
param databases databaseType[] = []

@description('Log Analytics workspace resource ID for database diagnostic settings, applied to every database in the databases list. Azure SQL emits diagnostics per database, not per logical server. Leave empty to skip diagnostics.')
param diagnosticsWorkspaceResourceId string = ''

@description('Public network access. Disabled by default: reach the server through a private endpoint.')
@allowed([
  'Disabled'
  'Enabled'
])
param publicNetworkAccess string = 'Disabled'

@description('Subnet resource ID for the private endpoint. Leave empty to skip the private endpoint.')
param privateEndpointSubnetResourceId string = ''

@description('Private DNS zone resource IDs for the endpoint, e.g. privatelink.database.windows.net.')
param privateDnsZoneResourceIds string[] = []

@description('Enable the system-assigned managed identity.')
param enableSystemAssignedIdentity bool = true

@description('Resource IDs of user-assigned managed identities to attach.')
param userAssignedIdentityResourceIds string[] = []

@description('RBAC role assignments on the server resource (management plane).')
param roleAssignments roleAssignmentType[] = []

var dnsZoneGroupConfigs = [
  for zoneResourceId in privateDnsZoneResourceIds: {
    privateDnsZoneResourceId: zoneResourceId
  }
]

module sqlServer 'br/public:avm/res/sql/server:0.22.1' = {
  name: '${take(name, 40)}-avm'
  params: {
    name: name
    location: location
    tags: tags
    // Secure defaults: Entra ID only, no SQL logins, TLS 1.2, private access
    administrators: {
      azureADOnlyAuthentication: true
      login: entraAdminLogin
      sid: entraAdminObjectId
      principalType: entraAdminPrincipalType
      tenantId: tenant().tenantId
    }
    minimalTlsVersion: '1.2'
    publicNetworkAccess: publicNetworkAccess
    databases: [
      for database in databases: {
        name: database.name
        sku: {
          name: database.skuName
          tier: database.skuTier
        }
        maxSizeBytes: database.?maxSizeBytes
        zoneRedundant: database.?zoneRedundant
        availabilityZone: database.?availabilityZone ?? -1
        diagnosticSettings: empty(diagnosticsWorkspaceResourceId)
          ? []
          : [
              { workspaceResourceId: diagnosticsWorkspaceResourceId }
            ]
      }
    ]
    privateEndpoints: empty(privateEndpointSubnetResourceId)
      ? []
      : [
          {
            service: 'sqlServer'
            subnetResourceId: privateEndpointSubnetResourceId
            tags: tags
            privateDnsZoneGroup: empty(dnsZoneGroupConfigs)
              ? null
              : {
                  privateDnsZoneGroupConfigs: dnsZoneGroupConfigs
                }
          }
        ]
    managedIdentities: {
      systemAssigned: enableSystemAssignedIdentity
      userAssignedResourceIds: userAssignedIdentityResourceIds
    }
    roleAssignments: roleAssignments
  }
}

@description('Resource ID of the server.')
output resourceId string = sqlServer.outputs.resourceId

@description('Name of the server.')
output name string = sqlServer.outputs.name

@description('Fully qualified domain name, e.g. <name>.database.windows.net.')
output fullyQualifiedDomainName string = sqlServer.outputs.fullyQualifiedDomainName

@description('Principal ID of the system-assigned identity. Empty when not enabled.')
output systemAssignedMIPrincipalId string = sqlServer.outputs.?systemAssignedMIPrincipalId ?? ''
