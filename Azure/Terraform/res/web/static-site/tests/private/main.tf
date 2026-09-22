# Internal-only app reachable through a private endpoint.
# Placeholder IDs: the test validates the module contract, it does not resolve these resources.
provider "azurerm" {
  features {}
}

module "test" {
  source = "../../"

  name                          = "swa-private-0001"
  location                      = "westeurope"
  resource_group_id             = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example"
  public_network_access_enabled = false

  private_endpoint = {
    subnet_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example/providers/Microsoft.Network/virtualNetworks/vnet-example/subnets/snet-private-endpoints"
    private_dns_zone_resource_ids = [
      "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-dns/providers/Microsoft.Network/privateDnsZones/privatelink.azurestaticapps.net",
    ]
  }
}
