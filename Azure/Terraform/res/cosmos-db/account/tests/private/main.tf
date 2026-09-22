# Serverless account with a second read region, a private endpoint and diagnostics.
# Placeholder IDs: the test validates the module contract, it does not resolve these resources.
provider "azurerm" {
  features {}
}

module "test" {
  source = "../../"

  name                      = "cosmos-private-0001"
  location                  = "westeurope"
  resource_group_id         = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example"
  serverless                = true
  additional_locations      = ["westus2"]
  enable_automatic_failover = true

  sql_databases = {
    sessions = {
      containers = {
        agent-sessions = {
          partition_key_paths = ["/sessionId"]
        }
      }
    }
  }

  private_endpoint = {
    subnet_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example/providers/Microsoft.Network/virtualNetworks/vnet-example/subnets/snet-private-endpoints"
    private_dns_zone_resource_ids = [
      "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-dns/providers/Microsoft.Network/privateDnsZones/privatelink.documents.azure.com",
    ]
  }

  diagnostics = {
    workspace_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example/providers/Microsoft.OperationalInsights/workspaces/log-example"
  }
}
