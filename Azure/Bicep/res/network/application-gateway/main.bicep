metadata name = 'Application Gateway'
metadata description = 'Layer 7 load balancer and reverse proxy with an attached WAF policy, HTTP routing to one or more backends (wraps AVM).'

import { roleAssignmentType } from '../../../utl/types/main.bicep'

@export()
@description('A backend target: a pool of IP addresses or FQDNs the gateway routes traffic to.')
type backendType = {
  @description('Name of the backend pool.')
  name: string

  @description('IP addresses in the pool, e.g. VM or VMSS private IPs.')
  ipAddresses: string[]?

  @description('FQDNs in the pool, e.g. an App Service default host name. Cannot be mixed with ipAddresses in the same pool.')
  fqdns: string[]?
}

@export()
@description('How the gateway talks to a backend: port, protocol and health probing.')
type backendSettingType = {
  @description('Name of the backend setting.')
  name: string

  @description('Port the gateway connects to on the backend.')
  port: int

  @description('Protocol the gateway uses to the backend. Https here is independent of whether clients reach the gateway over HTTP or HTTPS.')
  protocol: 'Http' | 'Https'

  @description('Path the gateway probes for backend health, e.g. "/healthz".')
  probePath: string

  @description('Send the original Host header to a backend that expects it (e.g. an App Service, which routes by host name), instead of the backend\'s own address.')
  pickHostNameFromBackendAddress: bool?
}

@export()
@description('What the gateway listens for on its frontend.')
type listenerType = {
  @description('Name of the listener.')
  name: string

  @description('Frontend port clients connect to.')
  port: int

  @description('Host header to match, for routing several sites off one gateway. Leave empty to match any host.')
  hostName: string?
}

@export()
@description('Routes a listener to a backend.')
type routingRuleType = {
  @description('Name of the rule.')
  name: string

  @description('Evaluation priority: lower runs first. Must be unique across all rules.')
  priority: int

  @description('Name of the listener this rule matches.')
  listenerName: string

  @description('Name of the backend pool traffic is sent to.')
  backendName: string

  @description('Name of the backend setting (port/protocol/probe) used to reach the backend.')
  backendSettingName: string
}

@description('Name of the gateway.')
param name string

@description('Azure region. Defaults to the resource group location.')
param location string = resourceGroup().location

@description('Tags applied to all resources.')
param tags object = {}

@description('WAF_v2 includes the WAF policy support this module attaches. Standard_v2 has no WAF and is cheaper if you don\'t need one.')
@allowed([
  'WAF_v2'
  'Standard_v2'
])
param skuName string = 'WAF_v2'

@description('Minimum and maximum instance count for autoscaling. v2 SKUs always autoscale.')
param autoscaleMinCapacity int = 0

@description('Maximum autoscale capacity.')
param autoscaleMaxCapacity int = 10

@description('Subnet resource ID for the gateway. Must be dedicated to Application Gateway, at least /27, with no other resources in it.')
param subnetResourceId string

@description('Resource ID of a public IP address for an internet-facing frontend. Leave empty for a fully internal gateway (requires privateFrontendIpAddress or a dynamic private IP in the subnet).')
param publicIpResourceId string = ''

@description('Static private IP address for the frontend, inside the gateway subnet. Leave empty for a dynamically assigned private IP.')
param privateFrontendIpAddress string = ''

@description('Resource ID of a WAF policy from the waf-policy module. Required when skuName is WAF_v2.')
param firewallPolicyResourceId string = ''

@description('Backend pools.')
@minLength(1)
param backends backendType[]

@description('Backend settings (port, protocol, health probe).')
@minLength(1)
param backendSettings backendSettingType[]

@description('Listeners. HTTP only in this module; HTTPS with certificate management is not covered yet, terminate TLS at Front Door in front of this gateway, or add it here later.')
@minLength(1)
param listeners listenerType[]

@description('Routing rules connecting listeners to backends.')
@minLength(1)
param routingRules routingRuleType[]

@description('Log Analytics workspace resource ID for diagnostic settings (access and firewall logs). Leave empty to skip diagnostics.')
param diagnosticsWorkspaceResourceId string = ''

@description('RBAC role assignments on the gateway.')
param roleAssignments roleAssignmentType[] = []

var gatewayIpConfigName = 'gateway'
var frontendIpConfigName = 'frontend'
var frontendPorts = union(map(listeners, listener => listener.port), [])
var uniqueFrontendPorts = union(frontendPorts, [])

module applicationGateway 'br/public:avm/res/network/application-gateway:0.10.0' = {
  name: '${take(name, 40)}-avm'
  params: {
    name: name
    location: location
    tags: tags
    sku: skuName
    autoscaleMinCapacity: autoscaleMinCapacity
    autoscaleMaxCapacity: autoscaleMaxCapacity
    firewallPolicyResourceId: skuName == 'WAF_v2' && !empty(firewallPolicyResourceId) ? firewallPolicyResourceId : null
    gatewayIPConfigurations: [
      {
        name: gatewayIpConfigName
        properties: {
          subnet: { id: subnetResourceId }
        }
      }
    ]
    frontendIPConfigurations: [
      {
        name: frontendIpConfigName
        properties: union(
          empty(publicIpResourceId) ? {} : { publicIPAddress: { id: publicIpResourceId } },
          empty(privateFrontendIpAddress)
            ? {}
            : {
                privateIPAddress: privateFrontendIpAddress
                privateIPAllocationMethod: 'Static'
                subnet: { id: subnetResourceId }
              }
        )
      }
    ]
    frontendPorts: map(uniqueFrontendPorts, port => {
      name: 'port-${port}'
      properties: { port: port }
    })
    backendAddressPools: map(backends, backend => {
      name: backend.name
      properties: {
        backendAddresses: concat(
          map(backend.?ipAddresses ?? [], ip => { ipAddress: ip }),
          map(backend.?fqdns ?? [], fqdn => { fqdn: fqdn })
        )
      }
    })
    backendHttpSettingsCollection: map(backendSettings, setting => {
      name: setting.name
      properties: {
        port: setting.port
        protocol: setting.protocol
        pickHostNameFromBackendAddress: setting.?pickHostNameFromBackendAddress ?? false
        probeEnabled: true
        probe: { id: resourceId('Microsoft.Network/applicationGateways/probes', name, '${setting.name}-probe') }
      }
    })
    probes: map(backendSettings, setting => {
      name: '${setting.name}-probe'
      properties: {
        protocol: setting.protocol
        path: setting.probePath
        interval: 30
        timeout: 30
        unhealthyThreshold: 3
        pickHostNameFromBackendHttpSettings: true
      }
    })
    httpListeners: map(listeners, listener => {
      name: listener.name
      properties: {
        frontendIPConfiguration: { id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', name, frontendIpConfigName) }
        frontendPort: { id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', name, 'port-${listener.port}') }
        protocol: 'Http'
        hostName: listener.?hostName
      }
    })
    requestRoutingRules: map(routingRules, rule => {
      name: rule.name
      properties: {
        ruleType: 'Basic'
        priority: rule.priority
        httpListener: { id: resourceId('Microsoft.Network/applicationGateways/httpListeners', name, rule.listenerName) }
        backendAddressPool: { id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', name, rule.backendName) }
        backendHttpSettings: { id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', name, rule.backendSettingName) }
      }
    })
    diagnosticSettings: empty(diagnosticsWorkspaceResourceId)
      ? []
      : [
          { workspaceResourceId: diagnosticsWorkspaceResourceId }
        ]
    roleAssignments: roleAssignments
  }
}

@description('Resource ID of the gateway.')
output resourceId string = applicationGateway.outputs.resourceId

@description('Name of the gateway.')
output name string = applicationGateway.outputs.name
