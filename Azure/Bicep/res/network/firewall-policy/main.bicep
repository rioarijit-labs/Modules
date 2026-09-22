metadata name = 'Azure Firewall policy'
metadata description = 'Rule collections (network, application and NAT) attached to an Azure Firewall (wraps AVM).'

import { roleAssignmentType } from '../../../utl/types/main.bicep'

@export()
@description('A network rule: matches on IP, port and protocol.')
type networkRuleType = {
  name: string
  ipProtocols: ('TCP' | 'UDP' | 'ICMP' | 'Any')[]
  sourceAddresses: string[]
  destinationAddresses: string[]
  destinationPorts: string[]
}

@export()
@description('An application rule: matches on FQDN, for HTTP/HTTPS traffic the firewall can inspect at the application layer.')
type applicationRuleType = {
  name: string
  sourceAddresses: string[]
  targetFqdns: string[]
  protocols: { protocolType: 'Http' | 'Https', port: int }[]
}

@export()
@description('A named, prioritized group of rule collections.')
type ruleCollectionGroupType = {
  @description('Name of the group.')
  name: string

  @description('Evaluation order relative to other groups. Lower runs first.')
  priority: int

  @description('Network rules in this group, wrapped in one Allow collection.')
  networkRules: networkRuleType[]?

  @description('Application rules in this group, wrapped in one Allow collection.')
  applicationRules: applicationRuleType[]?
}

@description('Name of the firewall policy.')
param name string

@description('Azure region. Defaults to the resource group location.')
param location string = resourceGroup().location

@description('Tags applied to the policy.')
param tags object = {}

@description('Standard has application/network/NAT rules. Premium adds TLS inspection, IDPS and URL filtering. Basic is a smaller, cheaper SKU with a lower rule and throughput ceiling.')
@allowed([
  'Basic'
  'Standard'
  'Premium'
])
param tier string = 'Standard'

@description('Alert only logs matching traffic. Deny also blocks it. Off disables intrusion detection. Premium tier only.')
@allowed([
  'Off'
  'Alert'
  'Deny'
])
param threatIntelMode string = 'Alert'

@description('Rule collection groups.')
param ruleCollectionGroups ruleCollectionGroupType[] = []

@description('RBAC role assignments on the policy.')
param roleAssignments roleAssignmentType[] = []

module firewallPolicy 'br/public:avm/res/network/firewall-policy:0.3.6' = {
  name: '${take(name, 40)}-avm'
  params: {
    name: name
    location: location
    tags: tags
    tier: tier
    threatIntelMode: threatIntelMode
    ruleCollectionGroups: [
      for group in ruleCollectionGroups: {
        name: group.name
        properties: {
          priority: group.priority
          ruleCollections: concat(
            empty(group.?networkRules ?? []) ? [] : [
              {
                ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
                name: '${group.name}-network'
                priority: group.priority
                action: { type: 'Allow' }
                rules: map(group.?networkRules ?? [], rule => {
                  ruleType: 'NetworkRule'
                  name: rule.name
                  ipProtocols: rule.ipProtocols
                  sourceAddresses: rule.sourceAddresses
                  destinationAddresses: rule.destinationAddresses
                  destinationPorts: rule.destinationPorts
                })
              }
            ],
            empty(group.?applicationRules ?? []) ? [] : [
              {
                ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
                name: '${group.name}-application'
                priority: group.priority + 1
                action: { type: 'Allow' }
                rules: map(group.?applicationRules ?? [], rule => {
                  ruleType: 'ApplicationRule'
                  name: rule.name
                  sourceAddresses: rule.sourceAddresses
                  targetFqdns: rule.targetFqdns
                  protocols: rule.protocols
                })
              }
            ]
          )
        }
      }
    ]
    roleAssignments: roleAssignments
  }
}

@description('Resource ID of the firewall policy. Pass this to the azure-firewall module\'s firewallPolicyResourceId.')
output resourceId string = firewallPolicy.outputs.resourceId

@description('Name of the firewall policy.')
output name string = firewallPolicy.outputs.name
