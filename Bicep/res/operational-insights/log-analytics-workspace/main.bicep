metadata name = 'Log Analytics workspace'
metadata description = 'Log Analytics workspace, the destination for diagnostic settings and monitoring data (wraps AVM).'

import { roleAssignmentType } from '../../../utl/types/main.bicep'

@description('Name of the workspace. 4-63 characters, letters, numbers and hyphens.')
@minLength(4)
@maxLength(63)
param name string

@description('Azure region. Defaults to the resource group location.')
param location string = resourceGroup().location

@description('Tags applied to the workspace.')
param tags object = {}

@description('Pricing SKU. PerGB2018 is pay-as-you-go.')
@allowed([
  'PerGB2018'
  'CapacityReservation'
  'Free'
])
param skuName string = 'PerGB2018'

@description('Days to retain data in the workspace. 30 is included in the price for most tables.')
@minValue(4)
@maxValue(730)
param retentionInDays int = 30

@description('Daily ingestion cap in GB as a string, decimals allowed (e.g. "0.5", "2"). "-1" means no cap. A cap protects cost but drops data once reached.')
param dailyQuotaGb string = '-1'

@description('Allow data ingestion over the public network. Disabling it requires an Azure Monitor Private Link Scope, otherwise diagnostics from other resources stop arriving.')
@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccessForIngestion string = 'Enabled'

@description('Allow queries over the public network. Disabling it requires an Azure Monitor Private Link Scope.')
@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccessForQuery string = 'Enabled'

@description('RBAC role assignments on the workspace, e.g. "Log Analytics Reader" for a support group.')
param roleAssignments roleAssignmentType[] = []

module workspace 'br/public:avm/res/operational-insights/workspace:0.16.1' = {
  name: '${take(name, 40)}-avm'
  params: {
    name: name
    location: location
    tags: tags
    skuName: skuName
    dataRetention: retentionInDays
    dailyQuotaGb: dailyQuotaGb
    publicNetworkAccessForIngestion: publicNetworkAccessForIngestion
    publicNetworkAccessForQuery: publicNetworkAccessForQuery
    roleAssignments: roleAssignments
  }
}

@description('Resource ID of the workspace. Pass this as diagnosticsWorkspaceResourceId to the other modules.')
output resourceId string = workspace.outputs.resourceId

@description('Name of the workspace.')
output name string = workspace.outputs.name

@description('Workspace (customer) ID, a GUID used by agents and queries.')
output logAnalyticsWorkspaceId string = workspace.outputs.logAnalyticsWorkspaceId
