# Cosmos DB account

Cosmos DB account using the SQL (Core) API, with databases and containers. Wraps `br/public:avm/res/document-db/database-account:0.21.1`.

## Defaults

- Public network access **disabled**, firewall bypass for trusted Azure services only
- API keys **disabled** (`disableLocalAuthentication` is always on): callers use Entra ID through the account's **own** RBAC system, not Azure RBAC
- `Session` consistency, `Provisioned` capacity mode, `Continuous` backup (point-in-time restore)
- Single region, no zone redundancy (cheap default; opt into `zoneRedundant` and `additionalLocations` for production)

## Two separate RBAC systems — don't confuse them

Cosmos DB has its own data-plane RBAC, independent of Azure RBAC:

| Parameter | Governs | Example role |
|---|---|---|
| `roleAssignments` | Azure RBAC, **management operations only** (create/list/delete the account) | `Cosmos DB Account Reader Role` |
| `dataRoleAssignments` | Cosmos DB's own RBAC, **reading and writing data** | `Reader`, `Contributor` |

Because API keys are always disabled, an application with `Contributor` on the account via `roleAssignments` still **cannot read a single document** until it also has an entry in `dataRoleAssignments`. This trips people up constantly; the module exists partly to make the split visible.

```bicep
dataRoleAssignments: [
  {
    principalId: app.outputs.systemAssignedMIPrincipalId
    role: 'Contributor'
  }
]
```

## Capacity mode

- `Provisioned` (default): reserve RU/s per container or database. Predictable cost, right for steady traffic.
- `Serverless`: pay per request, capped at 5000 RU/s total and incompatible with `enableFreeTier`. Cheaper for spiky, low-traffic or dev workloads.

## Multi-region

`location` is always the primary (write) region. Add `additionalLocations` (read regions) and set `enableAutomaticFailover` to promote one automatically if the primary fails. Multi-region roughly multiplies write cost by the number of regions.

## Usage

```bicep
module cosmos '../../res/cosmos-db/account/main.bicep' = {
  name: 'cosmos'
  params: {
    name: 'cosmos-catalog-001'
    sqlDatabases: [
      {
        name: 'catalog'
        throughput: 400
        containers: [
          { name: 'products', partitionKeyPaths: ['/category'] }
        ]
      }
    ]
    privateEndpointSubnetResourceId: vnet.outputs.subnetResourceIds[1]
    privateDnsZoneResourceIds: [cosmosZone.outputs.resourceId]
    dataRoleAssignments: [
      { principalId: app.outputs.systemAssignedMIPrincipalId, role: 'Contributor' }
    ]
  }
}
```

## Tests

- [tests/defaults](tests/defaults/main.test.bicep): single database, shared throughput, a reader data role
- [tests/private](tests/private/main.test.bicep): serverless, a second read region, private endpoint and diagnostics
