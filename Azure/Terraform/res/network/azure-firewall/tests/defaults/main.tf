# Standard firewall in a hub VNet with an attached policy and diagnostics.
# Placeholder IDs: the test validates the module contract, it does not resolve these resources.
provider "azurerm" {
  features {}
}

module "test" {
  source = "../../"

  name                        = "afw-hub-defaults"
  location                    = "westeurope"
  resource_group_id           = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-hub"
  subnet_resource_id          = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-hub/providers/Microsoft.Network/virtualNetworks/vnet-hub/subnets/AzureFirewallSubnet"
  public_ip_resource_id       = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-hub/providers/Microsoft.Network/publicIPAddresses/pip-afw-example"
  firewall_policy_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-hub/providers/Microsoft.Network/firewallPolicies/fwpolicy-example"

  diagnostics = {
    workspace_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example/providers/Microsoft.OperationalInsights/workspaces/log-example"
  }
}
