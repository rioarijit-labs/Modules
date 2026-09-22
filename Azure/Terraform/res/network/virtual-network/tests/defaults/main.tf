# Spoke network with a workload subnet, a private endpoint subnet and an App Service integration subnet.
# Placeholder IDs: the test validates the module contract, it does not resolve these resources.
module "test" {
  source = "../../"

  name              = "vnet-defaults"
  location          = "westeurope"
  resource_group_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example"
  address_space     = ["10.10.0.0/16"]

  subnets = {
    workload = {
      name           = "snet-workload"
      address_prefix = "10.10.0.0/24"
    }
    private_endpoints = {
      name                              = "snet-private-endpoints"
      address_prefix                    = "10.10.1.0/24"
      private_endpoint_network_policies = "Enabled"
    }
    app_integration = {
      name           = "snet-app-integration"
      address_prefix = "10.10.2.0/24"
      delegation     = "Microsoft.Web/serverFarms"
    }
  }
}
