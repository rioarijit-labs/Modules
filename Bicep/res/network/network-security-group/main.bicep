metadata name = 'Network security group'
metadata description = 'Network security group with an explicit deny-all inbound rule by default (wraps AVM).'

@export()
@description('A network security group rule. Set exactly one of each source/destination prefix and port pair (singular or plural form).')
type securityRuleType = {
  @description('Name of the rule.')
  name: string

  properties: {
    @description('Allow or Deny matching traffic.')
    access: 'Allow' | 'Deny'

    @description('Direction of matching traffic.')
    direction: 'Inbound' | 'Outbound'

    @description('Rule priority, 100-4096. Lower numbers are evaluated first and must be unique per direction.')
    @minValue(100)
    @maxValue(4096)
    priority: int

    @description('Network protocol.')
    protocol: '*' | 'Tcp' | 'Udp' | 'Icmp' | 'Ah' | 'Esp'

    @description('Description of the rule.')
    description: string?

    @description('Source address prefix, CIDR, service tag (e.g. "VirtualNetwork") or "*".')
    sourceAddressPrefix: string?

    @description('Source address prefixes or CIDRs.')
    sourceAddressPrefixes: string[]?

    @description('Source port or range, e.g. "*" or "1024-65535".')
    sourcePortRange: string?

    @description('Source ports or ranges.')
    sourcePortRanges: string[]?

    @description('Destination address prefix, CIDR, service tag or "*".')
    destinationAddressPrefix: string?

    @description('Destination address prefixes or CIDRs.')
    destinationAddressPrefixes: string[]?

    @description('Destination port or range, e.g. "443".')
    destinationPortRange: string?

    @description('Destination ports or ranges.')
    destinationPortRanges: string[]?
  }
}

@description('Name of the network security group.')
param name string

@description('Azure region. Defaults to the resource group location.')
param location string = resourceGroup().location

@description('Tags applied to the network security group.')
param tags object = {}

@description('Security rules to create.')
param securityRules securityRuleType[] = []

@description('Add an explicit inbound deny-all rule at priority 4096, so the intent is visible in the portal and in reviews.')
param denyAllInbound bool = true

@description('Log Analytics workspace resource ID for diagnostic settings. Leave empty to skip diagnostics.')
param diagnosticsWorkspaceResourceId string = ''

var denyAllInboundRule = {
  name: 'DenyAllInbound'
  properties: {
    access: 'Deny'
    direction: 'Inbound'
    priority: 4096
    protocol: '*'
    description: 'Deny all inbound traffic not matched by a higher-priority rule.'
    sourceAddressPrefix: '*'
    sourcePortRange: '*'
    destinationAddressPrefix: '*'
    destinationPortRange: '*'
  }
}

module networkSecurityGroup 'br/public:avm/res/network/network-security-group:0.5.3' = {
  name: '${take(name, 40)}-avm'
  params: {
    name: name
    location: location
    tags: tags
    securityRules: denyAllInbound ? concat(securityRules, [denyAllInboundRule]) : securityRules
    diagnosticSettings: empty(diagnosticsWorkspaceResourceId)
      ? []
      : [
          { workspaceResourceId: diagnosticsWorkspaceResourceId }
        ]
  }
}

@description('Resource ID of the network security group.')
output resourceId string = networkSecurityGroup.outputs.resourceId

@description('Name of the network security group.')
output name string = networkSecurityGroup.outputs.name
