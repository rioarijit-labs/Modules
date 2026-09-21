# Key Vault

Secure-by-default Key Vault. Wraps `br/public:avm/res/key-vault/vault:0.14.2`.

## Defaults

- **Azure RBAC** for authorization, no access policies
- Soft delete (90 days) and **purge protection** on
- Public network access **disabled**, firewall default action `Deny`
- `standard` SKU

## Notes

- **Purge protection cannot be turned off**, and a deleted vault keeps its name reserved for the retention period. For throwaway lab deployments, set `enablePurgeProtection` to false and use a unique name.
- The deploying identity needs a data-plane role (for example `Key Vault Secrets Officer`) to create secrets. This module creates no secrets: set them from a pipeline or reference them from other services.
- Grant apps `Key Vault Secrets User` through `roleAssignments`. Container Apps and App Service can then use Key Vault references, with no secret values in Bicep.

## Usage

```bicep
module keyVault '../../res/key-vault/key-vault/main.bicep' = {
  name: 'kv'
  params: {
    name: 'kv-example-001'
    privateEndpointSubnetResourceId: vnet.outputs.subnetResourceIds[1]
    privateDnsZoneResourceIds: [keyVaultZone.outputs.resourceId]
    roleAssignments: [
      {
        roleDefinitionIdOrName: 'Key Vault Secrets User'
        principalId: app.outputs.systemAssignedMIPrincipalId
        principalType: 'ServicePrincipal'
      }
    ]
  }
}
```

## Tests

- [tests/defaults](tests/defaults/main.test.bicep): private endpoint, diagnostics and a secrets reader role
