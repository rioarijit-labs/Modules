# Data lake with containers, blob and dfs private endpoints, DNS zone groups and diagnostics.
# Placeholder IDs: the test validates the module contract, it does not resolve these resources.
module "test" {
  source = "../../"

  name                          = "stprivate0001"
  location                      = "westeurope"
  resource_group_id             = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example"
  tags                          = { environment = "test" }
  enable_hierarchical_namespace = true
  container_names               = ["raw", "curated"]

  private_endpoint = {
    subnet_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example/providers/Microsoft.Network/virtualNetworks/vnet-example/subnets/snet-private-endpoints"
    services           = ["blob", "dfs"]
    private_dns_zone_resource_ids = {
      blob = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-dns/providers/Microsoft.Network/privateDnsZones/privatelink.blob.core.windows.net"
      dfs  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-dns/providers/Microsoft.Network/privateDnsZones/privatelink.dfs.core.windows.net"
    }
  }

  diagnostics = {
    workspace_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example/providers/Microsoft.OperationalInsights/workspaces/log-example"
  }
}
