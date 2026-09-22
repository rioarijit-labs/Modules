# Private DNS zone

Private DNS zone linked to virtual networks. Wraps `Azure/avm-res-network-privatednszone/azurerm` 0.5.0.

Private endpoints only work by name if the client resolves the service's `privatelink` name to the endpoint's private IP. Create each zone once, link it to every network that needs it, and pass its resource ID to the modules that create private endpoints.

## Zone names for common services

| Service | Zone |
|---|---|
| Storage blob | `privatelink.blob.core.windows.net` |
| Storage Data Lake | `privatelink.dfs.core.windows.net` |
| Key Vault | `privatelink.vaultcore.azure.net` |
| App Service | `privatelink.azurewebsites.net` |
| Foundry / Azure OpenAI | `privatelink.cognitiveservices.azure.com`, `privatelink.openai.azure.com`, `privatelink.services.ai.azure.com` |
| AI Search | `privatelink.search.windows.net` |
| Container Registry | `privatelink.azurecr.io` |
| Service Bus and Event Hubs | `privatelink.servicebus.windows.net` |
| Azure SQL Database | `privatelink.database.windows.net` |

Use the exact names: they are not free-form. Check the Azure docs for the current name if a service is not listed.

## Notes

- `virtual_network_resource_ids` is a **map** keyed by link name, for example `{ hub = module.hub.resource_id }`. The key must be known at plan time, the value may be computed. A list of IDs would make the link names unknown while the network is created in the same apply.
- Keep `registration_enabled` false for private endpoint zones. It is for VM auto-registration.
- In a hub and spoke, link the zone to the hub, and to spokes that resolve on their own instead of through a central DNS resolver or firewall DNS proxy.

## Usage

```hcl
module "blob_zone" {
  source = "../../res/network/private-dns-zone"

  name              = "privatelink.blob.core.windows.net"
  resource_group_id = azurerm_resource_group.this.id

  virtual_network_resource_ids = {
    spoke = module.network.resource_id
  }
}
```

## Tests

- [tests/defaults](tests/defaults/main.tf): blob zone linked to a hub and a spoke
