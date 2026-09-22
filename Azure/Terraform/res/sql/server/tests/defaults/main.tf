# Entra ID only server with a General Purpose serverless database and a private endpoint.
# Placeholder IDs: the test validates the module contract, it does not resolve these resources.
provider "azurerm" {
  features {}
}

module "test" {
  source = "../../"

  name                  = "sql-defaults-0001"
  location              = "westeurope"
  resource_group_id     = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example"
  entra_admin_login     = "sql-admins"
  entra_admin_object_id = "00000000-0000-0000-0000-000000000001"

  databases = {
    appdb = {
      sku_name = "GP_S_Gen5_2"
    }
  }

  private_endpoint = {
    subnet_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example/providers/Microsoft.Network/virtualNetworks/vnet-example/subnets/snet-private-endpoints"
    private_dns_zone_resource_ids = [
      "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-dns/providers/Microsoft.Network/privateDnsZones/privatelink.database.windows.net",
    ]
  }
}
