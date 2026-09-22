# Basic service with a private endpoint and index roles for an ingestion identity and a query identity.
# Placeholder IDs: the test validates the module contract, it does not resolve these resources.
provider "azurerm" {
  features {}
}

module "test" {
  source = "../../"

  name              = "srch-defaults-0001"
  location          = "westeurope"
  resource_group_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example"

  private_endpoint = {
    subnet_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example/providers/Microsoft.Network/virtualNetworks/vnet-example/subnets/snet-private-endpoints"
    private_dns_zone_resource_ids = [
      "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-dns/providers/Microsoft.Network/privateDnsZones/privatelink.search.windows.net",
    ]
  }

  role_assignments = {
    ingestion = {
      role_definition_id_or_name = "Search Index Data Contributor"
      principal_id               = "00000000-0000-0000-0000-000000000001"
      principal_type             = "ServicePrincipal"
    }
    query = {
      role_definition_id_or_name = "Search Index Data Reader"
      principal_id               = "00000000-0000-0000-0000-000000000002"
      principal_type             = "ServicePrincipal"
    }
  }
}
