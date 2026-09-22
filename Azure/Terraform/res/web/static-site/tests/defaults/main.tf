# Public Standard-tier app with a custom domain and app settings.
provider "azurerm" {
  features {}
}

module "test" {
  source = "../../"

  name              = "swa-defaults-0001"
  location          = "westeurope"
  resource_group_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example"

  custom_domain_names = ["www.example.com"]

  app_settings = {
    API_BASE_URL = "https://api.example.com"
  }
}
