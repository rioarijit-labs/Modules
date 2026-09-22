metadata name = 'Application Insights'
metadata description = 'Workspace-based Application Insights component for APM: request/dependency tracing, exceptions and live metrics (wraps AVM).'

import { roleAssignmentType } from '../../../utl/types/main.bicep'

@description('Name of the Application Insights component.')
param name string

@description('Azure region. Defaults to the resource group location.')
param location string = resourceGroup().location

@description('Tags applied to the component.')
param tags object = {}

@description('Resource ID of the Log Analytics workspace this component stores its data in. Workspace-based is the only supported mode; classic (standalone) Application Insights is retired.')
param logAnalyticsWorkspaceResourceId string

@description('Application type. web covers both web and non-web apps; other is used for some client SDK scenarios.')
@allowed([
  'web'
  'other'
])
param applicationType string = 'web'

@description('Days to retain telemetry. Independent of the underlying workspace\'s own retention.')
@minValue(30)
@maxValue(730)
param retentionInDays int = 90

@description('Percentage of telemetry to sample, to control cost on high-volume apps. 100 means no sampling.')
@minValue(0)
@maxValue(100)
param samplingPercentage int = 100

@description('Allow public network access for ingestion (the SDK sending telemetry). Disabling it requires an Azure Monitor Private Link Scope, otherwise telemetry stops arriving.')
@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccessForIngestion string = 'Enabled'

@description('Allow public network access for queries (reading telemetry, e.g. from the portal or an API). Disabling it requires an Azure Monitor Private Link Scope.')
@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccessForQuery string = 'Enabled'

@description('Disable API key based ingestion and access. Applications should send telemetry with Entra ID / Azure Monitor OpenTelemetry authentication instead.')
param disableLocalAuth bool = false

@description('RBAC role assignments on the component, e.g. "Monitoring Reader" for a support group.')
param roleAssignments roleAssignmentType[] = []

module applicationInsights 'br/public:avm/res/insights/component:0.8.0' = {
  name: '${take(name, 40)}-avm'
  params: {
    name: name
    location: location
    tags: tags
    workspaceResourceId: logAnalyticsWorkspaceResourceId
    applicationType: applicationType
    kind: applicationType
    retentionInDays: retentionInDays
    samplingPercentage: samplingPercentage
    publicNetworkAccessForIngestion: publicNetworkAccessForIngestion
    publicNetworkAccessForQuery: publicNetworkAccessForQuery
    disableLocalAuth: disableLocalAuth
    disableIpMasking: false
    roleAssignments: roleAssignments
  }
}

@description('Resource ID of the Application Insights component.')
output resourceId string = applicationInsights.outputs.resourceId

@description('Name of the Application Insights component.')
output name string = applicationInsights.outputs.name

@description('Connection string. Not a secret in the traditional sense (it identifies the ingestion endpoint, it does not grant read access), but avoid logging it unnecessarily. Set as an app setting on the app that sends telemetry.')
output connectionString string = applicationInsights.outputs.connectionString
