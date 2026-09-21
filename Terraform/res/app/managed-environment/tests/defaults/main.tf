# Internal environment in a delegated subnet with logs sent to Log Analytics.
# Placeholder IDs: the test validates the module contract, it does not resolve these resources.
provider "azurerm" {
  features {}
}

module "test" {
  source = "../../"

  name                              = "cae-defaults"
  location                          = "westeurope"
  resource_group_id                 = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example"
  infrastructure_subnet_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example/providers/Microsoft.Network/virtualNetworks/vnet-example/subnets/snet-container-apps"

  diagnostics = {
    workspace_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example/providers/Microsoft.OperationalInsights/workspaces/log-example"
  }
}
