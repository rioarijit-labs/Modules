metadata name = 'Azure Functions'
metadata description = 'Function app with keyless (identity-based) storage, secure-by-default, on a Consumption or a Premium/Dedicated plan (wraps AVM).'

import { roleAssignmentType } from '../../../utl/types/main.bicep'

@description('Name of the function app. Globally unique, it forms <name>.azurewebsites.net.')
@minLength(2)
@maxLength(60)
param name string

@description('Azure region. Defaults to the resource group location.')
param location string = resourceGroup().location

@description('Tags applied to all resources.')
param tags object = {}

@description('Resource ID of the hosting plan. Use the app-service-plan module with skuName "Y1" for classic Consumption, or a Premium ("EP1"-"EP3") or Dedicated plan for VNet integration and no cold start.')
param serverFarmResourceId string

@description('Operating system of the plan. Must match the plan.')
param osType string = 'Linux'

@description('Runtime worker, e.g. "dotnet-isolated", "node", "python", "java", "powershell".')
param workerRuntime string = 'node'

@description('Runtime version, e.g. "20" for node, "3.12" for python. Passed as the LinuxFxVersion on Linux.')
param runtimeVersion string = '20'

@description('Name of the storage account the Functions runtime uses (AzureWebJobsStorage). Create it with the storage-account module and grant this app\'s identity "Storage Blob Data Owner", "Storage Queue Data Contributor" and "Storage Table Data Contributor" on it, through that module\'s roleAssignments - identity-based storage access needs no connection string or key.')
param storageAccountName string

@description('Additional application settings, merged with the Functions runtime settings this module sets. Use Key Vault references (@Microsoft.KeyVault(...)) for secrets, never plain values.')
param appSettings object = {}

@description('Public network access. Disabled by default: reach the app through a private endpoint. Set to Enabled for internet-facing HTTP-triggered functions.')
@allowed([
  'Disabled'
  'Enabled'
])
param publicNetworkAccess string = 'Disabled'

@description('Subnet resource ID for regional VNet integration (outbound traffic, and required for the app to reach the storage account privately). The subnet must be delegated to Microsoft.Web/serverFarms.')
param virtualNetworkSubnetResourceId string = ''

@description('Subnet resource ID for the inbound private endpoint. Leave empty to skip the private endpoint.')
param privateEndpointSubnetResourceId string = ''

@description('Private DNS zone resource IDs for the endpoint, e.g. privatelink.azurewebsites.net.')
param privateDnsZoneResourceIds string[] = []

@description('Log Analytics workspace resource ID for diagnostic settings. Leave empty to skip diagnostics.')
param diagnosticsWorkspaceResourceId string = ''

@description('Enable the system-assigned managed identity. Needed for keyless storage access; leave this on unless you attach a user-assigned identity instead.')
param enableSystemAssignedIdentity bool = true

@description('Resource IDs of user-assigned managed identities to attach.')
param userAssignedIdentityResourceIds string[] = []

@description('RBAC role assignments on the app.')
param roleAssignments roleAssignmentType[] = []

var functionsAppSettings = {
  FUNCTIONS_EXTENSION_VERSION: '~4'
  FUNCTIONS_WORKER_RUNTIME: workerRuntime
  AzureWebJobsStorage__accountName: storageAccountName
  AzureWebJobsStorage__credential: 'managedidentity'
}

var dnsZoneGroupConfigs = [
  for zoneResourceId in privateDnsZoneResourceIds: {
    privateDnsZoneResourceId: zoneResourceId
  }
]

module functionApp 'br/public:avm/res/web/site:0.24.0' = {
  name: '${take(name, 40)}-avm'
  params: {
    name: name
    location: location
    tags: tags
    kind: osType == 'Linux' ? 'functionapp,linux' : 'functionapp'
    serverFarmResourceId: serverFarmResourceId
    storageAccountRequired: false // storage is wired through app settings above, not this legacy connection-string path
    // Secure defaults: HTTPS only, TLS 1.2, no FTP, private access
    httpsOnly: true
    publicNetworkAccess: publicNetworkAccess
    siteConfig: {
      linuxFxVersion: osType == 'Linux' ? '${toUpper(workerRuntime)}|${runtimeVersion}' : null
      minTlsVersion: '1.2'
      ftpsState: 'Disabled'
      http20Enabled: true
      use32BitWorkerProcess: false
    }
    basicPublishingCredentialsPolicies: [
      { name: 'scm', allow: false }
      { name: 'ftp', allow: false }
    ]
    configs: [
      {
        name: 'appsettings'
        properties: union(functionsAppSettings, appSettings)
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

@description('Resource ID of the function app.')
output resourceId string = functionApp.outputs.resourceId

@description('Name of the function app.')
output name string = functionApp.outputs.name

@description('Default host name of the function app.')
output defaultHostname string = functionApp.outputs.defaultHostname

@description('Principal ID of the system-assigned identity. Empty when not enabled. Grant it "Storage Blob Data Owner", "Storage Queue Data Contributor" and "Storage Table Data Contributor" on the storage account named in storageAccountName.')
output systemAssignedMIPrincipalId string = functionApp.outputs.?systemAssignedMIPrincipalId ?? ''
