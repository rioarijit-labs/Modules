# Pay-as-you-go workspace with 30 day retention and a 1 GB daily cap.
provider "azurerm" {
  features {}
}

module "test" {
  source = "../../"

  name              = "log-defaults"
  location          = "westeurope"
  resource_group_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example"
  daily_quota_gb    = 1
}
