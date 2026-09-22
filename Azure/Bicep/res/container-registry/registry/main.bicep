metadata name = 'Container registry'
metadata description = 'Azure Container Registry, private and Entra ID only by default (wraps AVM).'

import { roleAssignmentType } from '../../../utl/types/main.bicep'

@description('Name of the registry. 5-50 characters, letters and numbers only. Globally unique.')
@minLength(5)
@maxLength(50)
param name string

@description('Azure region. Defaults to the resource group location.')
param location string = resourceGroup().location

@description('Tags applied to all resources.')
param tags object = {}

@description('Registry tier. Private endpoints, zone redundancy and the firewall need Premium. Basic and Standard are public-only: set publicNetworkAccess to Enabled with them.')
@allowed([
  'Basic'
  'Standard'
  'Premium'
])
param skuName string = 'Premium'

@description('Public network access. Disabled by default: push and pull through a private endpoint (Premium).')
@allowed([
  'Disabled'
  'Enabled'
])
param publicNetworkAccess string = 'Disabled'

@description('Spread the registry across availability zones. Premium only.')
@allowed([
  'Enabled'
  'Disabled'
])
param zoneRedundancy string = 'Enabled'

@description('Subnet resource ID for the private endpoint. Leave empty to skip the private endpoint.')
param privateEndpointSubnetResourceId string = ''

@description('Private DNS zone resource IDs for the endpoint, e.g. privatelink.azurecr.io.')
param privateDnsZoneResourceIds string[] = []

@description('Log Analytics workspace resource ID for diagnostic settings. Leave empty to skip diagnostics.')
param diagnosticsWorkspaceResourceId string = ''

@description('Enable the system-assigned managed identity.')
param enableSystemAssignedIdentity bool = false

@description('RBAC role assignments on the registry, e.g. "AcrPull" for a workload identity or "AcrPush" for a build pipeline.')
param roleAssignments roleAssignmentType[] = []

var isPremium = skuName == 'Premium'
var dnsZoneGroupConfigs = [
  for zoneResourceId in privateDnsZoneResourceIds: {
    privateDnsZoneResourceId: zoneResourceId
  }
]

module registry 'br/public:avm/res/container-registry/registry:0.13.1' = {
  name: '${take(name, 40)}-avm'
  params: {
    name: name
    location: location
    tags: tags
    acrSku: skuName
    zoneRedundancy: isPremium ? zoneRedundancy : 'Disabled'
    // Secure defaults
    acrAdminUserEnabled: false
    anonymousPullEnabled: false
    exportPolicyStatus: 'disabled'
    azureADAuthenticationAsArmPolicyStatus: 'enabled'
    publicNetworkAccess: publicNetworkAccess
    // The firewall rule set is a Premium feature
    networkRuleSetDefaultAction: isPremium ? 'Deny' : 'Allow'
    networkRuleBypassOptions: 'AzureServices'
    privateEndpoints: empty(privateEndpointSubnetResourceId)
      ? []
      : [
          {
            service: 'registry'
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
    managedIdentities: {
      systemAssigned: enableSystemAssignedIdentity
    }
    roleAssignments: roleAssignments
  }
}

@description('Resource ID of the registry.')
output resourceId string = registry.outputs.resourceId

@description('Name of the registry.')
output name string = registry.outputs.name

@description('Login server, e.g. <name>.azurecr.io.')
output loginServer string = registry.outputs.loginServer
