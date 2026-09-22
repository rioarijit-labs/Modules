# Private endpoint

Private endpoint to any Azure PaaS resource, with optional private DNS zone group. Wraps `Azure/avm-res-network-privateendpoint/azurerm` 0.2.0.

The storage account, Key Vault, Foundry, App Service and other modules can create their own private endpoints. Use this module for resources whose module has no such option, or to add an endpoint to an existing resource.

## Common group IDs and DNS zones

| Service | `group_ids` | Private DNS zone |
|---|---|---|
| Storage blob | `blob` | `privatelink.blob.core.windows.net` |
| Storage Data Lake | `dfs` | `privatelink.dfs.core.windows.net` |
| Key Vault | `vault` | `privatelink.vaultcore.azure.net` |
| App Service | `sites` | `privatelink.azurewebsites.net` |
| Foundry / Azure OpenAI | `account` | `privatelink.cognitiveservices.azure.com`, `privatelink.openai.azure.com`, `privatelink.services.ai.azure.com` |
| Azure SQL | `sqlServer` | `privatelink.database.windows.net` |

## Usage

```hcl
module "key_vault_endpoint" {
  source = "../../res/network/private-endpoint"

  name                             = "pe-kv-example"
  location                         = "westeurope"
  resource_group_id                = azurerm_resource_group.this.id
  subnet_resource_id               = module.network.subnet_resource_ids["private_endpoints"]
  private_link_service_resource_id = azurerm_key_vault.this.id
  group_ids                        = ["vault"]
  private_dns_zone_resource_ids    = [module.key_vault_zone.resource_id]
}
```

## Tests

- [tests/defaults](tests/defaults/main.tf): blob endpoint with DNS zone group
