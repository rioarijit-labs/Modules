metadata name = 'Front Door'
metadata description = 'Azure Front Door (Standard or Premium) profile: global HTTPS entry point with a CDN cache and origin health probing, routing to one backend origin group (wraps AVM).'

import { roleAssignmentType } from '../../../utl/types/main.bicep'

@export()
@description('A backend origin Front Door routes traffic to and health-probes.')
type originType = {
  @description('Name of the origin.')
  name: string

  @description('Host name of the origin, e.g. an App Service default host name or a public load balancer FQDN.')
  hostName: string

  @description('Relative priority when multiple origins are configured: 1 is highest. Traffic goes to the highest-priority healthy origin.')
  priority: int?

  @description('Weight for traffic splitting between origins at the same priority.')
  weight: int?
}

@description('Name of the Front Door profile.')
param name string

@description('Tags applied to all resources.')
param tags object = {}

@description('Standard is CDN plus global load balancing. Premium adds a WAF-capable security layer, private link to origins and bot protection.')
@allowed([
  'Standard_AzureFrontDoor'
  'Premium_AzureFrontDoor'
])
param skuName string = 'Standard_AzureFrontDoor'

@description('Name of the public endpoint. Forms <endpointName>-<hash>.z01.azurefd.net unless a custom domain is added.')
param endpointName string = name

@description('Origins in the single origin group this module creates. Front Door probes each and routes only to healthy ones.')
@minLength(1)
param origins originType[]

@description('Path Front Door requests to check origin health, e.g. "/healthz".')
param healthProbePath string = '/'

@description('Protocol used between Front Door and the origins.')
@allowed([
  'Http'
  'Https'
])
param originProtocol string = 'Https'

@description('URL path patterns this route matches, e.g. ["/*"] for everything.')
param routePatterns string[] = ['/*']

@description('Custom domain names to bind, e.g. ["www.example.com"]. DNS (a CNAME to the endpoint, or an ALIAS/ANAME at the zone apex) must already point at Front Door; this only registers the binding and requests the managed TLS certificate.')
param customDomainNames string[] = []

@description('Log Analytics workspace resource ID for diagnostic settings (access and WAF logs). Leave empty to skip diagnostics.')
param diagnosticsWorkspaceResourceId string = ''

@description('Enable the system-assigned managed identity, needed for Key Vault-sourced TLS certificates on custom domains.')
param enableSystemAssignedIdentity bool = false

@description('RBAC role assignments on the profile.')
param roleAssignments roleAssignmentType[] = []

var originGroupName = 'default'
var routeName = 'default'

module frontDoorProfile 'br/public:avm/res/cdn/profile:0.20.0' = {
  name: '${take(name, 40)}-avm'
  params: {
    name: name
    tags: tags
    sku: skuName
    originGroups: [
      {
        name: originGroupName
        loadBalancingSettings: {
          sampleSize: 4
          successfulSamplesRequired: 3
        }
        healthProbeSettings: {
          probePath: healthProbePath
          probeProtocol: originProtocol
          probeRequestType: 'HEAD'
          probeIntervalInSeconds: 30
        }
        origins: [
          for origin in origins: {
            name: origin.name
            hostName: origin.hostName
            originHostHeader: origin.hostName
            httpPort: 80
            httpsPort: 443
            priority: origin.?priority ?? 1
            weight: origin.?weight ?? 1000
            enabledState: 'Enabled'
          }
        ]
      }
    ]
    afdEndpoints: [
      {
        name: endpointName
        enabledState: 'Enabled'
        routes: [
          {
            name: routeName
            originGroupName: originGroupName
            patternsToMatch: routePatterns
            supportedProtocols: ['Http', 'Https']
            forwardingProtocol: originProtocol == 'Https' ? 'HttpsOnly' : 'HttpOnly'
            httpsRedirect: 'Enabled'
            linkToDefaultDomain: 'Enabled'
          }
        ]
      }
    ]
    customDomains: [
      for domainName in customDomainNames: {
        name: replace(domainName, '.', '-')
        hostName: domainName
        certificateType: 'ManagedCertificate'
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

@description('Resource ID of the Front Door profile.')
output resourceId string = frontDoorProfile.outputs.resourceId

@description('Name of the profile.')
output name string = frontDoorProfile.outputs.name

@description('Default host name of the endpoint, e.g. <endpointName>-<hash>.z01.azurefd.net. Point a custom domain\'s CNAME at this.')
output endpointHostName string = frontDoorProfile.outputs.frontDoorEndpointHostNames[0]
