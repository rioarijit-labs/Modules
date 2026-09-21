# Linux Node app with a managed identity, VNet integration, health check and a private endpoint.
# Placeholder IDs: the test validates the module contract, it does not resolve these resources.
module "test" {
  source = "../../"

  name                     = "app-defaults-0001"
  location                 = "westeurope"
  resource_group_id        = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example"
  service_plan_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example/providers/Microsoft.Web/serverfarms/asp-example"
  linux_fx_version         = "NODE|20-lts"
  health_check_path        = "/healthz"

  app_settings = {
    WEBSITE_RUN_FROM_PACKAGE = "1"
  }

  virtual_network_subnet_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example/providers/Microsoft.Network/virtualNetworks/vnet-example/subnets/snet-app-integration"

  private_endpoint = {
    subnet_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example/providers/Microsoft.Network/virtualNetworks/vnet-example/subnets/snet-private-endpoints"
  }
}
