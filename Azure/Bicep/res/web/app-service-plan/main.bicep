metadata name = 'App Service plan'
metadata description = 'App Service plan for Linux or Windows web apps and function apps (wraps AVM).'

@description('Name of the App Service plan.')
param name string

@description('Azure region. Defaults to the resource group location.')
param location string = resourceGroup().location

@description('Tags applied to all resources.')
param tags object = {}

@description('Operating system of the plan.')
@allowed([
  'Linux'
  'Windows'
])
param osType string = 'Linux'

@description('Pricing SKU, e.g. "B1", "P1v3", "P0v3", "S1". Zone redundancy requires a Premium v2/v3 SKU.')
param skuName string = 'P1v3'

@description('Number of instances. Zone redundancy requires at least 3.')
@minValue(1)
@maxValue(30)
param skuCapacity int = 1

@description('Spread instances across availability zones.')
param zoneRedundant bool = false

@description('Log Analytics workspace resource ID for diagnostic settings. Leave empty to skip diagnostics.')
param diagnosticsWorkspaceResourceId string = ''

module appServicePlan 'br/public:avm/res/web/serverfarm:0.7.0' = {
  name: '${take(name, 40)}-avm'
  params: {
    name: name
    location: location
    tags: tags
    kind: osType
    reserved: osType == 'Linux'
    skuName: skuName
    skuCapacity: skuCapacity
    zoneRedundant: zoneRedundant
    diagnosticSettings: empty(diagnosticsWorkspaceResourceId)
      ? []
      : [
          { workspaceResourceId: diagnosticsWorkspaceResourceId }
        ]
  }
}

@description('Resource ID of the App Service plan.')
output resourceId string = appServicePlan.outputs.resourceId

@description('Name of the App Service plan.')
output name string = appServicePlan.outputs.name
