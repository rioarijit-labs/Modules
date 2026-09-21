# Private endpoint

Private endpoint to any Azure PaaS resource, with optional private DNS zone group. Wraps `br/public:avm/res/network/private-endpoint:0.12.1`.

The storage account, Foundry and App Service modules can create their own private endpoints. Use this module for resources whose module has no such option, or to add an endpoint to an existing resource.

## Common group IDs and DNS zones

| Service | `groupIds` | Private DNS zone |
|---|---|---|
| Storage blob | `blob` | `privatelink.blob.core.windows.net` |
| Storage Data Lake | `dfs` | `privatelink.dfs.core.windows.net` |
| Key Vault | `vault` | `privatelink.vaultcore.azure.net` |
| App Service | `sites` | `privatelink.azurewebsites.net` |
| Foundry / Azure OpenAI | `account` | `privatelink.cognitiveservices.azure.com`, `privatelink.openai.azure.com`, `privatelink.services.ai.azure.com` |
| Azure SQL | `sqlServer` | `privatelink.database.windows.net` |

## Usage

```bicep
module keyVaultEndpoint '../../res/network/private-endpoint/main.bicep' = {
  name: 'pe-kv'
  params: {
    name: 'pe-kv-example'
    subnetResourceId: vnet.outputs.subnetResourceIds[1]
    privateLinkServiceResourceId: keyVaultResourceId
    groupIds: ['vault']
    privateDnsZoneResourceIds: [keyVaultPrivateDnsZoneResourceId]
  }
}
```

## Tests

- [tests/defaults](tests/defaults/main.test.bicep): blob endpoint with DNS zone group
