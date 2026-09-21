# Storage account

Secure-by-default storage account. Wraps `br/public:avm/res/storage/storage-account:0.33.1`.

## Defaults

- Public network access **disabled**, firewall default action `Deny`
- Shared key access and anonymous blob access **disabled**, Entra ID is the default authentication
- HTTPS only, TLS 1.2
- Blob and container soft delete, 7 days
- Zone-redundant (`Standard_ZRS`)

Data plane access needs a private endpoint: set `privateEndpointSubnetResourceId`. To reach the account publicly, set `publicNetworkAccess` to `Enabled` and add firewall rules deliberately.

## Usage

```bicep
module storage '../../res/storage/storage-account/main.bicep' = {
  name: 'storage'
  params: {
    name: 'stexample001'
    containerNames: ['raw', 'curated']
    privateEndpointSubnetResourceId: vnet.outputs.subnetResourceIds[1]
    privateDnsZoneResourceIds: {
      blob: blobPrivateDnsZoneResourceId
    }
    roleAssignments: [
      {
        roleDefinitionIdOrName: 'Storage Blob Data Contributor'
        principalId: app.outputs.systemAssignedMIPrincipalId
        principalType: 'ServicePrincipal'
      }
    ]
  }
}
```

## Tests

- [tests/defaults](tests/defaults/main.test.bicep): secure defaults only
- [tests/private](tests/private/main.test.bicep): data lake with blob and dfs private endpoints and diagnostics
