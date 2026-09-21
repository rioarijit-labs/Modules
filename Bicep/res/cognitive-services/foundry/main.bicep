metadata name = 'Azure AI Foundry'
metadata description = 'Azure AI Foundry resource (AIServices account) with model deployments, Foundry projects and private networking (wraps AVM).'

import { roleAssignmentType } from '../../../utl/types/main.bicep'

@export()
@description('A model deployment on the Foundry resource.')
type modelDeploymentType = {
  @description('Deployment name. This is the name applications call.')
  name: string

  model: {
    @description('Model format / provider, e.g. "OpenAI".')
    format: string

    @description('Model name, e.g. "gpt-4o".')
    name: string

    @description('Model version, e.g. "2024-11-20".')
    version: string
  }

  sku: {
    @description('Deployment SKU, e.g. "GlobalStandard", "Standard" or "ProvisionedManaged".')
    name: string

    @description('Capacity in thousands of tokens per minute (or PTUs for provisioned SKUs).')
    capacity: int
  }?
}

@export()
@description('A Foundry project, the unit teams work in (agents, evaluations, files).')
type projectType = {
  @description('Resource name of the project.')
  name: string

  @description('Friendly name shown in the portal. Defaults to the resource name.')
  displayName: string?

  @description('Description of the project.')
  description: string?
}

@description('Name of the Foundry resource. 2-64 characters; also used as the default custom subdomain.')
@minLength(2)
@maxLength(64)
param name string

@description('Azure region. Defaults to the resource group location. Check model availability per region.')
param location string = resourceGroup().location

@description('Tags applied to all resources.')
param tags object = {}

@description('Custom subdomain for the endpoint. Required for Microsoft Entra ID authentication and private networking. Globally unique.')
param customSubDomainName string = name

@description('SKU of the Foundry resource.')
param skuName string = 'S0'

@description('Model deployments to create.')
param modelDeployments modelDeploymentType[] = []

@description('Foundry projects to create.')
param projects projectType[] = []

@description('Public network access. Disabled by default: reach the resource through a private endpoint.')
@allowed([
  'Disabled'
  'Enabled'
])
param publicNetworkAccess string = 'Disabled'

@description('Disable API key authentication so only Microsoft Entra ID is accepted.')
param disableLocalAuth bool = true

@description('Subnet resource ID for the private endpoint. Leave empty to skip the private endpoint.')
param privateEndpointSubnetResourceId string = ''

@description('Private DNS zone resource IDs for the endpoint. Foundry needs privatelink.cognitiveservices.azure.com, privatelink.openai.azure.com and privatelink.services.ai.azure.com.')
param privateDnsZoneResourceIds string[] = []

@description('Log Analytics workspace resource ID for diagnostic settings. Leave empty to skip diagnostics.')
param diagnosticsWorkspaceResourceId string = ''

@description('Resource IDs of user-assigned managed identities to attach, in addition to the system-assigned identity.')
param userAssignedIdentityResourceIds string[] = []

@description('RBAC role assignments on the Foundry resource, e.g. "Cognitive Services OpenAI User" for an app identity.')
param roleAssignments roleAssignmentType[] = []

var dnsZoneGroupConfigs = [
  for zoneResourceId in privateDnsZoneResourceIds: {
    privateDnsZoneResourceId: zoneResourceId
  }
]

module foundry 'br/public:avm/res/cognitive-services/account:0.19.1' = {
  name: '${take(name, 40)}-avm'
  params: {
    name: name
    location: location
    tags: tags
    kind: 'AIServices'
    sku: skuName
    customSubDomainName: customSubDomainName
    // Required for Foundry projects
    allowProjectManagement: true
    // Secure defaults
    disableLocalAuth: disableLocalAuth
    publicNetworkAccess: publicNetworkAccess
    networkAcls: {
      defaultAction: 'Deny'
      bypass: 'AzureServices'
    }
    managedIdentities: {
      systemAssigned: true
      userAssignedResourceIds: userAssignedIdentityResourceIds
    }
    deployments: modelDeployments
    privateEndpoints: empty(privateEndpointSubnetResourceId)
      ? []
      : [
          {
            service: 'account'
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

resource foundryAccount 'Microsoft.CognitiveServices/accounts@2025-06-01' existing = {
  name: name
}

resource foundryProjects 'Microsoft.CognitiveServices/accounts/projects@2025-06-01' = [
  for project in projects: {
    parent: foundryAccount
    name: project.name
    location: location
    tags: tags
    identity: {
      type: 'SystemAssigned'
    }
    properties: {
      displayName: project.?displayName ?? project.name
      description: project.?description ?? ''
    }
    dependsOn: [
      foundry
    ]
  }
]

@description('Resource ID of the Foundry resource.')
output resourceId string = foundry.outputs.resourceId

@description('Name of the Foundry resource.')
output name string = foundry.outputs.name

@description('Endpoint of the Foundry resource.')
output endpoint string = foundry.outputs.endpoint

@description('Principal ID of the system-assigned identity.')
output systemAssignedMIPrincipalId string = foundry.outputs.?systemAssignedMIPrincipalId ?? ''

@description('Resource IDs of the Foundry projects, in the order they were declared.')
output projectResourceIds string[] = [for (project, i) in projects: foundryProjects[i].id]
