metadata name = 'App Service'
metadata description = 'Secure-by-default App Service web app or function app with managed identity, VNet integration and private endpoint (wraps AVM).'

import { roleAssignmentType } from '../../../utl/types/main.bicep'

@description('Name of the app. Globally unique, it forms <name>.azurewebsites.net.')
@minLength(2)
@maxLength(60)
param name string

@description('Azure region. Defaults to the resource group location.')
param location string = resourceGroup().location

@description('Tags applied to all resources.')
param tags object = {}

@description('Resource ID of the App Service plan to run on.')
param serverFarmResourceId string

@description('Kind of app.')
@allowed([
  'app'
  'app,linux'
  'app,linux,container'
  'functionapp'
  'functionapp,linux'
])
param kind string = 'app,linux'

@description('Runtime stack for Linux apps, e.g. "NODE|20-lts", "PYTHON|3.12", "DOTNETCORE|9.0". Leave empty for Windows apps.')
param linuxFxVersion string = ''

@description('Keep the app loaded. Requires Basic tier or above.')
param alwaysOn bool = true

@description('Path the platform probes to check instance health, e.g. "/healthz". Leave empty to disable.')
param healthCheckPath string = ''

@description('Application settings. Use Key Vault references (@Microsoft.KeyVault(...)) for secrets, never plain values.')
param appSettings object = {}

@description('Public network access. Disabled by default: reach the app through a private endpoint. Set to Enabled for internet-facing apps.')
@allowed([
  'Disabled'
  'Enabled'
])
param publicNetworkAccess string = 'Disabled'

@description('Subnet resource ID for regional VNet integration (outbound traffic). The subnet must be delegated to Microsoft.Web/serverFarms. Leave empty to skip.')
param virtualNetworkSubnetResourceId string = ''

@description('Subnet resource ID for the inbound private endpoint. Leave empty to skip the private endpoint.')
param privateEndpointSubnetResourceId string = ''

@description('Private DNS zone resource IDs for the endpoint, e.g. privatelink.azurewebsites.net.')
param privateDnsZoneResourceIds string[] = []

@description('Log Analytics workspace resource ID for diagnostic settings. Leave empty to skip diagnostics.')
param diagnosticsWorkspaceResourceId string = ''

@description('Enable the system-assigned managed identity.')
param enableSystemAssignedIdentity bool = true

@description('Resource IDs of user-assigned managed identities to attach.')
param userAssignedIdentityResourceIds string[] = []

@description('RBAC role assignments on the app.')
param roleAssignments roleAssignmentType[] = []

var dnsZoneGroupConfigs = [
  for zoneResourceId in privateDnsZoneResourceIds: {
    privateDnsZoneResourceId: zoneResourceId
  }
]

module appService 'br/public:avm/res/web/site:0.24.0' = {
  name: '${take(name, 40)}-avm'
  params: {
    name: name
    location: location
    tags: tags
    kind: kind
    serverFarmResourceId: serverFarmResourceId
    // Secure defaults
    httpsOnly: true
    publicNetworkAccess: publicNetworkAccess
    siteConfig: {
      linuxFxVersion: linuxFxVersion
      alwaysOn: alwaysOn
      minTlsVersion: '1.2'
      ftpsState: 'Disabled'
      http20Enabled: true
      healthCheckPath: healthCheckPath
    }
    // Deployments use Entra ID / managed identity, not publishing credentials
    basicPublishingCredentialsPolicies: [
      { name: 'scm', allow: false }
      { name: 'ftp', allow: false }
    ]
    configs: empty(appSettings)
      ? []
      : [
          {
            name: 'appsettings'
            properties: appSettings
          }
        ]
    virtualNetworkSubnetResourceId: empty(virtualNetworkSubnetResourceId) ? null : virtualNetworkSubnetResourceId
    managedIdentities: {
      systemAssigned: enableSystemAssignedIdentity
      userAssignedResourceIds: userAssignedIdentityResourceIds
    }
    privateEndpoints: empty(privateEndpointSubnetResourceId)
      ? []
      : [
          {
            service: 'sites'
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

@description('Resource ID of the app.')
output resourceId string = appService.outputs.resourceId

@description('Name of the app.')
output name string = appService.outputs.name

@description('Default host name of the app.')
output defaultHostname string = appService.outputs.defaultHostname

@description('Principal ID of the system-assigned identity. Empty when not enabled.')
output systemAssignedMIPrincipalId string = appService.outputs.?systemAssignedMIPrincipalId ?? ''
