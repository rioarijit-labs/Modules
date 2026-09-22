# Private endpoint to the blob service of a storage account, with a private DNS zone group.
# Placeholder IDs: the test validates the module contract, it does not resolve these resources.
provider "azurerm" {
  features {}
}

module "test" {
  source = "../../"

  name                             = "pe-defaults"
  location                         = "westeurope"
  resource_group_id                = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example"
  subnet_resource_id               = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example/providers/Microsoft.Network/virtualNetworks/vnet-example/subnets/snet-private-endpoints"
  private_link_service_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example/providers/Microsoft.Storage/storageAccounts/stexample"
  group_ids                        = ["blob"]
  private_dns_zone_resource_ids = [
    "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-dns/providers/Microsoft.Network/privateDnsZones/privatelink.blob.core.windows.net",
  ]
}
