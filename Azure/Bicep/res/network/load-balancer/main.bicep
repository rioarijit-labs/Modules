metadata name = 'Load balancer'
metadata description = 'Internal (private) load balancer distributing traffic across backend instances, with health probes (wraps AVM).'

import { roleAssignmentType } from '../../../utl/types/main.bicep'

@export()
@description('A load-balanced port mapping. Backend pool and probe are referenced by the names declared in backendPoolNames and probes.')
type loadBalancingRuleType = {
  @description('Name of the rule.')
  name: string

  @description('Transport protocol.')
  protocol: 'Tcp' | 'Udp'

  @description('Port clients connect to on the frontend.')
  frontendPort: int

  @description('Port traffic is forwarded to on the backend instances.')
  backendPort: int

  @description('Name of the backend pool this rule sends traffic to.')
  backendPoolName: string

  @description('Name of the health probe this rule uses.')
  probeName: string
}

@export()
@description('A health probe used by one or more load balancing rules.')
type probeType = {
  @description('Name of the probe.')
  name: string

  @description('Probe protocol.')
  protocol: 'Tcp' | 'Http' | 'Https'

  @description('Port to probe.')
  port: int

  @description('HTTP(S) path to probe, e.g. "/healthz". Required for Http and Https protocols.')
  requestPath: string?

  @description('Seconds between probes.')
  intervalInSeconds: int?

  @description('Consecutive failures before an instance is marked unhealthy.')
  numberOfProbes: int?
}

@description('Name of the load balancer.')
param name string

@description('Azure region. Defaults to the resource group location.')
param location string = resourceGroup().location

@description('Tags applied to the load balancer.')
param tags object = {}

@description('SKU. Standard is required for zone redundancy and is the only tier with a security-by-default posture (Basic allows all traffic by default with no NSG needed, which is easy to get wrong).')
@allowed([
  'Basic'
  'Standard'
])
param skuName string = 'Standard'

@description('Subnet resource ID for the frontend IP. This module always creates an internal (private) load balancer, never a public one.')
param subnetResourceId string

@description('Static private IP address for the frontend. Leave empty for a dynamically assigned address.')
param frontendPrivateIpAddress string = ''

@description('Names of the backend pools to create. Add instances to a pool from the VM or VMSS side after deployment.')
@minLength(1)
param backendPoolNames string[]

@description('Health probes.')
param probes probeType[] = []

@description('Load balancing rules.')
param loadBalancingRules loadBalancingRuleType[] = []

@description('Log Analytics workspace resource ID for diagnostic settings. Leave empty to skip diagnostics.')
param diagnosticsWorkspaceResourceId string = ''

@description('RBAC role assignments on the load balancer.')
param roleAssignments roleAssignmentType[] = []

var frontendName = 'frontend'

module loadBalancer 'br/public:avm/res/network/load-balancer:0.8.0' = {
  name: '${take(name, 40)}-avm'
  params: {
    name: name
    location: location
    tags: tags
    skuName: skuName
    frontendIPConfigurations: [
      {
        name: frontendName
        subnetResourceId: subnetResourceId
        // privateIPAllocationMethod is not exposed here: the module infers Static when privateIPAddress is set, Dynamic otherwise
        privateIPAddress: empty(frontendPrivateIpAddress) ? null : frontendPrivateIpAddress
      }
    ]
    backendAddressPools: [
      for poolName in backendPoolNames: {
        name: poolName
      }
    ]
    probes: [
      for probe in probes: {
        name: probe.name
        protocol: probe.protocol
        port: probe.port
        requestPath: probe.?requestPath
        intervalInSeconds: probe.?intervalInSeconds ?? 15
        numberOfProbes: probe.?numberOfProbes ?? 2
      }
    ]
    loadBalancingRules: [
      for rule in loadBalancingRules: {
        name: rule.name
        protocol: rule.protocol
        frontendPort: rule.frontendPort
        backendPort: rule.backendPort
        frontendIPConfigurationName: frontendName
        backendAddressPoolNames: [rule.backendPoolName]
        probeName: rule.probeName
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

@description('Resource ID of the load balancer.')
output resourceId string = loadBalancer.outputs.resourceId

@description('Name of the load balancer.')
output name string = loadBalancer.outputs.name
