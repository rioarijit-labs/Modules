metadata name = 'Example - private web app with storage and Foundry'
metadata description = 'Composes the modules in this repo: a spoke VNet protected by NSGs, an App Service integrated with it, and Storage and Foundry reachable only through private endpoints. The app identity gets data-plane access without keys.'

targetScope = 'resourceGroup'

@description('Short workload name used in resource names, e.g. "orders".')
@minLength(2)
@maxLength(12)
param workload string

@description('Environment name used in resource names.')
@allowed(['dev', 'test', 'prod'])
param environmentName string = 'dev'

@description('Azure region.')
param location string = resourceGroup().location

@description('Address space of the spoke network.')
param addressPrefix string = '10.20.0.0/22'

@description('Private DNS zone resource IDs, keyed by purpose. Leave a key out to manage DNS elsewhere. Keys: blob, sites, foundry (array of the three Foundry zones).')
param privateDnsZones object = {}

@description('Log Analytics workspace resource ID for diagnostics. Leave empty to skip.')
param diagnosticsWorkspaceResourceId string = ''

var tags = {
  workload: workload
  environment: environmentName
  managedBy: 'bicep'
}
var suffix = '${workload}-${environmentName}'
var uniqueSuffix = uniqueString(resourceGroup().id, workload)

var appName = 'app-${suffix}-${take(uniqueSuffix, 6)}'
var storageName = take('st${workload}${environmentName}${uniqueSuffix}', 24)
var foundryName = take('aif-${suffix}-${uniqueSuffix}', 64)

var peSubnetName = 'snet-private-endpoints'
var appSubnetName = 'snet-app-integration'

module peNsg '../../res/network/network-security-group/main.bicep' = {
  name: 'nsg-pe-${suffix}'
  params: {
    name: 'nsg-pe-${suffix}'
    location: location
    tags: tags
    diagnosticsWorkspaceResourceId: diagnosticsWorkspaceResourceId
    securityRules: [
      {
        name: 'AllowVnetInbound'
        properties: {
          access: 'Allow'
          direction: 'Inbound'
          priority: 100
          protocol: 'Tcp'
          sourceAddressPrefix: 'VirtualNetwork'
          sourcePortRange: '*'
          destinationAddressPrefix: 'VirtualNetwork'
          destinationPortRange: '443'
        }
      }
    ]
  }
}

module appNsg '../../res/network/network-security-group/main.bicep' = {
  name: 'nsg-app-${suffix}'
  params: {
    name: 'nsg-app-${suffix}'
    location: location
    tags: tags
    diagnosticsWorkspaceResourceId: diagnosticsWorkspaceResourceId
  }
}

module vnet '../../res/network/virtual-network/main.bicep' = {
  name: 'vnet-${suffix}'
  params: {
    name: 'vnet-${suffix}'
    location: location
    tags: tags
    addressPrefixes: [addressPrefix]
    diagnosticsWorkspaceResourceId: diagnosticsWorkspaceResourceId
    subnets: [
      {
        name: peSubnetName
        addressPrefix: cidrSubnet(addressPrefix, 24, 0)
        networkSecurityGroupResourceId: peNsg.outputs.resourceId
        privateEndpointNetworkPolicies: 'Enabled'
      }
      {
        name: appSubnetName
        addressPrefix: cidrSubnet(addressPrefix, 24, 1)
        networkSecurityGroupResourceId: appNsg.outputs.resourceId
        delegation: 'Microsoft.Web/serverFarms'
      }
    ]
  }
}

// Subnet IDs come back in declaration order.
var peSubnetResourceId = vnet.outputs.subnetResourceIds[0]
var appSubnetResourceId = vnet.outputs.subnetResourceIds[1]

module plan '../../res/web/app-service-plan/main.bicep' = {
  name: 'asp-${suffix}'
  params: {
    name: 'asp-${suffix}'
    location: location
    tags: tags
    diagnosticsWorkspaceResourceId: diagnosticsWorkspaceResourceId
  }
}

module app '../../res/web/app-service/main.bicep' = {
  name: 'app-${suffix}'
  params: {
    name: appName
    location: location
    tags: tags
    serverFarmResourceId: plan.outputs.resourceId
    linuxFxVersion: 'PYTHON|3.12'
    healthCheckPath: '/healthz'
    virtualNetworkSubnetResourceId: appSubnetResourceId
    privateEndpointSubnetResourceId: peSubnetResourceId
    privateDnsZoneResourceIds: contains(privateDnsZones, 'sites') ? [privateDnsZones.sites] : []
    diagnosticsWorkspaceResourceId: diagnosticsWorkspaceResourceId
    appSettings: {
      STORAGE_BLOB_ENDPOINT: storage.outputs.primaryBlobEndpoint
      FOUNDRY_ENDPOINT: foundry.outputs.endpoint
    }
  }
}

module storage '../../res/storage/storage-account/main.bicep' = {
  name: 'st-${suffix}'
  params: {
    name: storageName
    location: location
    tags: tags
    containerNames: ['data']
    privateEndpointSubnetResourceId: peSubnetResourceId
    privateDnsZoneResourceIds: contains(privateDnsZones, 'blob') ? { blob: privateDnsZones.blob } : {}
    diagnosticsWorkspaceResourceId: diagnosticsWorkspaceResourceId
  }
}

module foundry '../../res/cognitive-services/foundry/main.bicep' = {
  name: 'aif-${suffix}'
  params: {
    name: foundryName
    location: location
    tags: tags
    privateEndpointSubnetResourceId: peSubnetResourceId
    privateDnsZoneResourceIds: privateDnsZones.?foundry ?? []
    diagnosticsWorkspaceResourceId: diagnosticsWorkspaceResourceId
    projects: [
      { name: 'proj-${workload}' }
    ]
    modelDeployments: [
      {
        name: 'gpt-4o'
        model: { format: 'OpenAI', name: 'gpt-4o', version: '2024-11-20' }
        sku: { name: 'GlobalStandard', capacity: 10 }
      }
    ]
  }
}

// The app identity reads and writes blobs and calls the models with Entra ID, no keys.
// Role assignments live here, not in the modules, because the app depends on both resources' outputs.
resource storageAccount 'Microsoft.Storage/storageAccounts@2025-01-01' existing = {
  name: storageName
}

resource foundryAccount 'Microsoft.CognitiveServices/accounts@2025-06-01' existing = {
  name: foundryName
}

var storageBlobDataContributorRoleId = 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
var cognitiveServicesOpenAiUserRoleId = '5e0bd9bd-7b93-4f28-af87-19fc36ad61bd'

resource appBlobAccess 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: storageAccount
  name: guid(storageAccount.id, appName, storageBlobDataContributorRoleId)
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', storageBlobDataContributorRoleId)
    principalId: app.outputs.systemAssignedMIPrincipalId
    principalType: 'ServicePrincipal'
  }
}

resource appModelAccess 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: foundryAccount
  name: guid(foundryAccount.id, appName, cognitiveServicesOpenAiUserRoleId)
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', cognitiveServicesOpenAiUserRoleId)
    principalId: app.outputs.systemAssignedMIPrincipalId
    principalType: 'ServicePrincipal'
  }
}

@description('Default host name of the web app.')
output appHostname string = app.outputs.defaultHostname

@description('Resource ID of the spoke virtual network.')
output vnetResourceId string = vnet.outputs.resourceId
