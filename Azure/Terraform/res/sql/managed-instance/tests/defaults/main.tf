# General Purpose 4 vCore instance with an Entra ID admin group and one database.
# Placeholder IDs: the test validates the module contract, it does not resolve these resources.
provider "azurerm" {
  features {}
}

module "test" {
  source = "../../"

  name               = "sqlmi-defaults-0001"
  location           = "westeurope"
  resource_group_id  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example"
  subnet_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example/providers/Microsoft.Network/virtualNetworks/vnet-example/subnets/snet-sqlmi"

  entra_admin = {
    login     = "sql-admins"
    object_id = "00000000-0000-0000-0000-000000000001"
  }

  database_names = ["appdb"]
}
