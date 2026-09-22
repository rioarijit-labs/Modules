metadata name = 'Static Web App'
metadata description = 'Static Web App for a frontend or SPA, with optional Standard-tier private endpoint (wraps AVM).'

import { roleAssignmentType } from '../../../utl/types/main.bicep'

@description('Name of the static web app. 2-40 characters. Forms the default <name>.<region>.azurestaticapps.net hostname unless a custom domain is added.')
@minLength(2)
@maxLength(40)
param name string

@description('Azure region. Static Web Apps deploy to a smaller set of regions than most services; check availability first. Defaults to the resource group location.')
param location string = resourceGroup().location

@description('Tags applied to all resources.')
param tags object = {}

@description('Free has no SLA, no custom auth providers and no private endpoint. Standard is required for a private endpoint, staging environments beyond the free limit and a support SLA.')
@allowed([
  'Free'
  'Standard'
])
param skuName string = 'Standard'

@description('Public network access. Unlike most modules in this repo, this defaults to Enabled: a static site is usually meant to be reached over the public internet, and Standard-only features like custom domains and the managed CDN assume that. Set to Disabled, and add a private endpoint, for an internal-only site.')
@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccess string = 'Enabled'

@description('Subnet resource ID for the private endpoint. Standard SKU only. Leave empty to skip the private endpoint.')
param privateEndpointSubnetResourceId string = ''

@description('Private DNS zone resource IDs for the endpoint, e.g. privatelink.azurestaticapps.net.')
param privateDnsZoneResourceIds string[] = []

@description('Custom domain names to bind to the app, e.g. ["www.example.com"]. DNS must already point at the app; this only registers the binding.')
param customDomainNames string[] = []

@description('Application settings, available to the API functions at runtime. Use Key Vault references (@Microsoft.KeyVault(...)) for secrets, never plain values.')
param appSettings object = {}

@description('Source control integration: repositoryUrl, branch and a repositoryToken (a GitHub or Azure DevOps PAT, pass as a secure value) let the resource itself set up CI/CD. Leave null to deploy content another way, for example with the SWA CLI or a separate GitHub Actions workflow using the app\'s deployment token, which avoids storing a repository PAT in Bicep state.')
param repository {
  provider: 'GitHub' | 'DevOps'
  repositoryUrl: string
  branch: string
  @secure()
  repositoryToken: string
  appLocation: string?
  apiLocation: string?
  outputLocation: string?
}?

@description('Enable the system-assigned managed identity, used by managed functions to reach other resources.')
param enableSystemAssignedIdentity bool = false

@description('RBAC role assignments on the app, e.g. "Contributor" for a deployment identity.')
param roleAssignments roleAssignmentType[] = []

var dnsZoneGroupConfigs = [
  for zoneResourceId in privateDnsZoneResourceIds: {
    privateDnsZoneResourceId: zoneResourceId
  }
]

module staticWebApp 'br/public:avm/res/web/static-site:0.9.6' = {
  name: '${take(name, 40)}-avm'
  params: {
    name: name
    location: location
    tags: tags
    sku: skuName
    publicNetworkAccess: publicNetworkAccess
    provider: repository != null ? repository!.provider : 'None'
    repositoryUrl: repository != null ? repository!.repositoryUrl : ''
    branch: repository != null ? repository!.branch : ''
    repositoryToken: repository != null ? repository!.repositoryToken : ''
    buildProperties: repository == null
      ? null
      : {
          appLocation: repository!.?appLocation
          apiLocation: repository!.?apiLocation
          outputLocation: repository!.?outputLocation
        }
    customDomains: [
      for domainName in customDomainNames: {
        name: domainName
      }
    ]
    appSettings: appSettings
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
    managedIdentities: {
      systemAssigned: enableSystemAssignedIdentity
    }
    roleAssignments: roleAssignments
  }
}

@description('Resource ID of the static web app.')
output resourceId string = staticWebApp.outputs.resourceId

@description('Name of the static web app.')
output name string = staticWebApp.outputs.name

@description('Default host name, e.g. <name>.azurestaticapps.net.')
output defaultHostname string = staticWebApp.outputs.defaultHostname

@description('Principal ID of the system-assigned identity. Empty when not enabled.')
output systemAssignedMIPrincipalId string = staticWebApp.outputs.?systemAssignedMIPrincipalId ?? ''
