metadata name = 'Azure Firewall'
metadata description = 'Stateful, managed network firewall for a hub network, with a firewall policy attached for its rules (wraps AVM).'

import { roleAssignmentType } from '../../../utl/types/main.bicep'

@description('Name of the firewall.')
param name string

@description('Azure region. Defaults to the resource group location.')
param location string = resourceGroup().location

@description('Tags applied to all resources.')
param tags object = {}

@description('Standard has network, application and NAT rules. Premium adds TLS inspection, IDPS and URL filtering. Basic is a smaller, cheaper SKU. Must be compatible with the tier of the attached firewall-policy module.')
@allowed([
  'Basic'
  'Standard'
  'Premium'
])
param skuTier string = 'Standard'

@description('Resource ID of the hub virtual network. It must contain a subnet named exactly "AzureFirewallSubnet", at least /26.')
param virtualNetworkResourceId string

@description('Resource ID of an existing public IP to use for outbound SNAT. Leave empty to create one automatically.')
param publicIpResourceId string = ''

@description('Resource ID of a firewall policy from the firewall-policy module. Required in practice: without one, the firewall has no rules and blocks everything.')
param firewallPolicyResourceId string

@description('Spread the firewall across availability zones. Not available in every region.')
param availabilityZones (1 | 2 | 3)[] = []

@description('Log Analytics workspace resource ID for diagnostic settings. Leave empty to skip diagnostics.')
param diagnosticsWorkspaceResourceId string = ''

@description('RBAC role assignments on the firewall.')
param roleAssignments roleAssignmentType[] = []

module azureFirewall 'br/public:avm/res/network/azure-firewall:0.11.1' = {
  name: '${take(name, 40)}-avm'
  params: {
    name: name
    location: location
    tags: tags
    azureSkuTier: skuTier
    virtualNetworkResourceId: virtualNetworkResourceId
    publicIPResourceID: empty(publicIpResourceId) ? '' : publicIpResourceId
    firewallPolicyId: firewallPolicyResourceId
    availabilityZones: availabilityZones
    diagnosticSettings: empty(diagnosticsWorkspaceResourceId)
      ? []
      : [
          { workspaceResourceId: diagnosticsWorkspaceResourceId }
        ]
    roleAssignments: roleAssignments
  }
}

@description('Resource ID of the firewall.')
output resourceId string = azureFirewall.outputs.resourceId

@description('Name of the firewall.')
output name string = azureFirewall.outputs.name

@description('Private IP address of the firewall. Point a route table\'s default route at this address.')
output privateIpAddress string = azureFirewall.outputs.privateIp
