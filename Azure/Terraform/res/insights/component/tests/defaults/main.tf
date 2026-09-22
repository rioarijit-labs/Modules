# Workspace-based component with a shorter retention and sampling for cost control.
# Placeholder IDs: the test validates the module contract, it does not resolve these resources.
provider "azurerm" {
  features {}
}

module "test" {
  source = "../../"

  name                       = "appi-defaults"
  location                   = "westeurope"
  resource_group_id          = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example"
  log_analytics_workspace_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example/providers/Microsoft.OperationalInsights/workspaces/log-example"
  retention_in_days          = 30
  sampling_percentage        = 50
}
