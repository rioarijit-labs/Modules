# A one-off job container with plain and secret environment variables, placed in a subnet.
# Placeholder IDs: the test validates the module contract, it does not resolve these resources.
provider "azurerm" {
  features {}
}

module "test" {
  source = "../../"

  name               = "aci-defaults"
  location           = "westeurope"
  resource_group_id  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example"
  subnet_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example/providers/Microsoft.Network/virtualNetworks/vnet-example/subnets/snet-workload"
  restart_policy     = "Never"

  containers = {
    job = {
      image    = "mcr.microsoft.com/azure-cli:latest"
      cpu      = 1
      memory   = 2
      commands = ["az", "account", "show"]
      environment_variables = {
        LOG_LEVEL = "info"
      }
      secure_environment_variables = {
        API_KEY = "placeholder-not-a-real-secret"
      }
    }
  }
}
