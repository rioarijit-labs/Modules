# Standard profile routing to an App Service origin, with a custom domain.
provider "azurerm" {
  features {}
}

module "test" {
  source = "../../"

  name              = "afd-defaults"
  resource_group_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example"

  origins = {
    app_origin = {
      host_name = "app-example-001.azurewebsites.net"
    }
  }

  health_probe_path   = "/healthz"
  custom_domain_names = ["www.example.com"]
}
