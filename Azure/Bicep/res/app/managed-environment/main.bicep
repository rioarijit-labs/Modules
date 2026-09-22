metadata name = 'Container Apps environment'
metadata description = 'Container Apps managed environment with optional VNet integration, private endpoint and Log Analytics logging (wraps AVM).'

@description('Name of the environment.')
@minLength(2)
@maxLength(60)
param name string

@description('Azure region. Defaults to the resource group location.')
param location string = resourceGroup().location

@description('Tags applied to all resources.')
param tags object = {}

@description('Subnet resource ID for the environment infrastructure. It must be delegated to Microsoft.App/environments and be at least /27. Leave empty for a non-VNet environment.')
param infrastructureSubnetResourceId string = ''

@description('Internal load balancer: apps get a private IP and are only reachable from the VNet. Only applies when infrastructureSubnetResourceId is set.')
param internal bool = true

@description('Spread the environment across availability zones. Requires infrastructureSubnetResourceId.')
param zoneRedundant bool = false

@description('Public network access. Disabled by default: reach the environment from the VNet or through a private endpoint.')
@allowed([
  'Disabled'
  'Enabled'
])
param publicNetworkAccess string = 'Disabled'

@description('Subnet resource ID for a private endpoint to the environment. Leave empty to skip the private endpoint.')
param privateEndpointSubnetResourceId string = ''

@description('Private DNS zone resource IDs for the endpoint. The zone is privatelink.<region>.azurecontainerapps.io.')
param privateDnsZoneResourceIds string[] = []

@description('Log Analytics workspace resource ID for the environment logs. Leave empty to skip logging.')
param diagnosticsWorkspaceResourceId string = ''

var hasVnet = !empty(infrastructureSubnetResourceId)
var dnsZoneGroupConfigs = [
  for zoneResourceId in privateDnsZoneResourceIds: {
    privateDnsZoneResourceId: zoneResourceId
  }
]

module managedEnvironment 'br/public:avm/res/app/managed-environment:0.16.0' = {
  name: '${take(name, 40)}-avm'
  params: {
    name: name
    location: location
    tags: tags
    infrastructureSubnetResourceId: infrastructureSubnetResourceId
    internal: hasVnet && internal
    zoneRedundant: hasVnet && zoneRedundant
    publicNetworkAccess: publicNetworkAccess
    // Workload profiles environment with the pay-per-use Consumption profile
    workloadProfiles: [
      {
        name: 'Consumption'
        workloadProfileType: 'Consumption'
      }
    ]
    // Logs go through diagnostic settings to Log Analytics, so no workspace shared key is passed around
    appLogsConfiguration: empty(diagnosticsWorkspaceResourceId)
      ? null
      : {
          destination: 'azure-monitor'
        }
    diagnosticSettings: empty(diagnosticsWorkspaceResourceId)
      ? []
      : [
          {
            workspaceResourceId: diagnosticsWorkspaceResourceId
            logCategoriesAndGroups: [
              { categoryGroup: 'allLogs' }
            ]
          }
        ]
    privateEndpoints: empty(privateEndpointSubnetResourceId)
      ? []
      : [
          {
            service: 'managedEnvironments'
            subnetResourceId: privateEndpointSubnetResourceId
            tags: tags
            privateDnsZoneGroup: empty(dnsZoneGroupConfigs)
              ? null
              : {
                  privateDnsZoneGroupConfigs: dnsZoneGroupConfigs
                }
          }
        ]
  }
}

@description('Resource ID of the environment. Pass this as environmentResourceId to the container-app module.')
output resourceId string = managedEnvironment.outputs.resourceId

@description('Name of the environment.')
output name string = managedEnvironment.outputs.name

@description('Default domain of the environment, the suffix of every app FQDN.')
output defaultDomain string = managedEnvironment.outputs.defaultDomain

@description('Static IP of the environment load balancer. Only set for internal environments in a VNet, empty otherwise. Create a private DNS zone record for it.')
output staticIp string = managedEnvironment.outputs.?staticIp ?? ''
