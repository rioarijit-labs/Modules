metadata name = 'Azure Firewall - defaults'
metadata description = 'Standard firewall in a hub VNet with an attached policy and diagnostics.'

// Placeholder IDs: the test validates the module contract, it does not resolve these resources.
module test '../../main.bicep' = {
  name: 'test-azure-firewall-defaults'
  params: {
    name: 'afw-hub-defaults'
    virtualNetworkResourceId: '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-hub/providers/Microsoft.Network/virtualNetworks/vnet-hub'
    firewallPolicyResourceId: '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-hub/providers/Microsoft.Network/firewallPolicies/fwpolicy-example'
    diagnosticsWorkspaceResourceId: '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example/providers/Microsoft.OperationalInsights/workspaces/log-example'
  }
}
