metadata name = 'API Management'
metadata description = 'API Management gateway for publishing, securing and observing APIs, with OpenAPI-imported APIs (wraps AVM).'

import { roleAssignmentType } from '../../../utl/types/main.bicep'

@export()
@description('An API imported from an OpenAPI specification.')
type apiType = {
  @description('Resource name of the API (URL-safe identifier).')
  name: string

  @description('Display name shown in the developer portal.')
  displayName: string

  @description('URL path segment the API is exposed under, e.g. "orders" for https://<gateway>/orders/...')
  path: string

  @description('URL to an OpenAPI (Swagger) specification, JSON or YAML, publicly reachable or reachable from the APIM VNet.')
  openApiSpecUrl: string

  @description('Require a subscription key to call this API.')
  subscriptionRequired: bool?
}

@description('Name of the APIM instance. Globally unique, forms <name>.azure-api.net.')
@minLength(1)
@maxLength(50)
param name string

@description('Azure region. Defaults to the resource group location.')
param location string = resourceGroup().location

@description('Tags applied to all resources.')
param tags object = {}

@description('Contact email for the API publisher (shown to API consumers).')
param publisherEmail string

@description('Organization name shown in the developer portal.')
param publisherName string

@description('Developer has no SLA and no VNet integration but is inexpensive, a reasonable default for a showcase or dev environment. Standard/Basic add an SLA, still no VNet. Premium and the newer StandardV2/PremiumV2 SKUs support VNet integration and multi-region.')
@allowed([
  'Consumption'
  'Developer'
  'Basic'
  'Standard'
  'Premium'
  'BasicV2'
  'StandardV2'
  'PremiumV2'
])
param skuName string = 'Developer'

@description('Number of scale units. Ignored for Consumption.')
@minValue(1)
param skuCapacity int = 1

@description('External: APIM has a public IP with the gateway also reachable from the subnet. Internal: no public IP, gateway reachable only from the VNet. Premium or PremiumV2 only; leave None on other SKUs.')
@allowed([
  'None'
  'External'
  'Internal'
])
param virtualNetworkType string = 'None'

@description('Subnet resource ID for VNet integration. Required when virtualNetworkType is not None.')
param subnetResourceId string = ''

@description('APIs to import from an OpenAPI specification.')
param apis apiType[] = []

@description('Public network access to the management, portal and gateway endpoints. Only meaningful (and relevant to disable) on Premium/PremiumV2 with a private endpoint.')
@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccess string = 'Enabled'

@description('Subnet resource ID for a private endpoint to the management plane. Premium/PremiumV2 only. Leave empty to skip.')
param privateEndpointSubnetResourceId string = ''

@description('Private DNS zone resource IDs for the endpoint, e.g. privatelink.azure-api.net.')
param privateDnsZoneResourceIds string[] = []

@description('Log Analytics workspace resource ID for diagnostic settings. Leave empty to skip diagnostics.')
param diagnosticsWorkspaceResourceId string = ''

@description('Enable the system-assigned managed identity, used for Key Vault-backed named values and certificates.')
param enableSystemAssignedIdentity bool = true

@description('RBAC role assignments on the APIM resource (management plane).')
param roleAssignments roleAssignmentType[] = []

var dnsZoneGroupConfigs = [
  for zoneResourceId in privateDnsZoneResourceIds: {
    privateDnsZoneResourceId: zoneResourceId
  }
]

module apiManagement 'br/public:avm/res/api-management/service:0.14.4' = {
  name: '${take(name, 40)}-avm'
  params: {
    name: name
    location: location
    tags: tags
    publisherEmail: publisherEmail
    publisherName: publisherName
    sku: skuName
    skuCapacity: skuName == 'Consumption' ? 0 : skuCapacity
    virtualNetworkType: virtualNetworkType
    subnetResourceId: empty(subnetResourceId) ? null : subnetResourceId
    publicNetworkAccess: publicNetworkAccess
    apis: [
      for api in apis: {
        name: api.name
        displayName: api.displayName
        path: api.path
        format: 'openapi-link'
        value: api.openApiSpecUrl
        protocols: ['https']
        subscriptionRequired: api.?subscriptionRequired ?? true
      }
    ]
    privateEndpoints: empty(privateEndpointSubnetResourceId)
      ? []
      : [
          {
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

@description('Resource ID of the APIM instance.')
output resourceId string = apiManagement.outputs.resourceId

@description('Name of the APIM instance.')
output name string = apiManagement.outputs.name

@description('Principal ID of the system-assigned identity. Empty when not enabled.')
output systemAssignedMIPrincipalId string = apiManagement.outputs.?systemAssignedMIPrincipalId ?? ''
