metadata name = 'SQL Managed Instance'
metadata description = 'Azure SQL Managed Instance in a delegated subnet, Entra ID only with no public data endpoint (wraps AVM).'

import { roleAssignmentType } from '../../../utl/types/main.bicep'

@description('Name of the managed instance. 1-63 characters, lowercase letters, numbers and hyphens. Globally unique.')
@minLength(1)
@maxLength(63)
param name string

@description('Azure region. Defaults to the resource group location.')
param location string = resourceGroup().location

@description('Tags applied to all resources.')
param tags object = {}

@description('Resource ID of the dedicated subnet. It must be delegated to Microsoft.Sql/managedInstances, be at least /27, and have the NSG and route table Managed Instance requires. See the README.')
param subnetResourceId string

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

@description('Service tier.')
@allowed([
  'GeneralPurpose'
  'BusinessCritical'
])
param skuTier string = 'GeneralPurpose'

@description('Hardware and tier SKU name, must match skuTier. GP_Gen5 for General Purpose, BC_Gen5 for Business Critical.')
param skuName string = 'GP_Gen5'

@description('Number of vCores.')
@allowed([
  4
  8
  16
  24
  32
  40
  64
  80
])
param vCores int = 4

@description('Reserved storage in GB.')
@minValue(32)
@maxValue(8192)
param storageSizeInGB int = 32

@description('Licensing. Use BasePrice to apply Azure Hybrid Benefit.')
@allowed([
  'LicenseIncluded'
  'BasePrice'
])
param licenseType string = 'LicenseIncluded'

@description('Spread the instance across availability zones. Business Critical or regions with zone support only.')
param zoneRedundant bool = false

@description('Where automated backups are stored.')
@allowed([
  'Geo'
  'GeoZone'
  'Local'
  'Zone'
])
param backupStorageRedundancy string = 'Geo'

@description('Names of databases to create on the instance.')
param databaseNames string[] = []

@description('Log Analytics workspace resource ID for diagnostic settings. Leave empty to skip diagnostics.')
param diagnosticsWorkspaceResourceId string = ''

@description('RBAC role assignments on the instance resource (management plane).')
param roleAssignments roleAssignmentType[] = []

module managedInstance 'br/public:avm/res/sql/managed-instance:0.5.0' = {
  name: '${take(name, 40)}-avm'
  params: {
    name: name
    location: location
    tags: tags
    subnetResourceId: subnetResourceId
    skuName: skuName
    skuTier: skuTier
    vCores: vCores
    storageSizeInGB: storageSizeInGB
    licenseType: licenseType
    zoneRedundant: zoneRedundant
    requestedBackupStorageRedundancy: backupStorageRedundancy
    // Secure defaults: Entra ID only, no SQL logins, no public data endpoint
    administrators: {
      azureADOnlyAuthentication: true
      login: entraAdminLogin
      sid: entraAdminObjectId
      principalType: entraAdminPrincipalType
      tenantId: tenant().tenantId
    }
    publicDataEndpointEnabled: false
    minimalTlsVersion: '1.2'
    // The instance identity is used to read Entra ID; grant it the "Directory Readers" role
    managedIdentities: {
      systemAssigned: true
    }
    databases: [
      for databaseName in databaseNames: {
        name: databaseName
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

@description('Resource ID of the managed instance.')
output resourceId string = managedInstance.outputs.resourceId

@description('Name of the managed instance.')
output name string = managedInstance.outputs.name

@description('Principal ID of the system-assigned identity. Grant it the Entra ID "Directory Readers" role so Entra logins work.')
output systemAssignedMIPrincipalId string = managedInstance.outputs.?systemAssignedMIPrincipalId ?? ''
