# Blob private endpoint zone linked to a hub and a spoke network.
# Placeholder IDs: the test validates the module contract, it does not resolve these resources.
module "test" {
  source = "../../"

  name              = "privatelink.blob.core.windows.net"
  resource_group_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-dns"

  virtual_network_resource_ids = {
    hub   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-hub/providers/Microsoft.Network/virtualNetworks/vnet-hub"
    spoke = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-spoke/providers/Microsoft.Network/virtualNetworks/vnet-spoke"
  }
}
