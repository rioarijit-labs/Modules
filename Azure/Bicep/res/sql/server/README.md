# SQL Server

Azure SQL logical server with one or more single databases. Wraps `br/public:avm/res/sql/server:0.22.1`.

## Defaults

- **Entra ID only** authentication (`azureADOnlyAuthentication: true`): no SQL logins, no SQL admin password anywhere
- Public network access **disabled**, TLS 1.2 minimum
- System-assigned managed identity

## SQL DB vs SQL Managed Instance vs Cosmos DB

This repo also has [sql/managed-instance](../managed-instance) and [cosmos-db/account](../../cosmos-db/account). Use this module (SQL Database) for a standard PaaS relational database with no instance-level features needed. Use Managed Instance when you need near-100% SQL Server compatibility (SQL Agent, cross-database queries, linked servers) for a lift-and-shift. Use Cosmos DB for a non-relational, globally distributed store.

## SKUs

`skuName`/`skuTier` accept any valid Azure SQL Database combination, for example:

| skuTier | skuName | Notes |
|---|---|---|
| `GeneralPurpose` | `GP_S_Gen5_2` | Serverless, scales to zero, good default for dev/variable load |
| `GeneralPurpose` | `GP_Gen5_4` | Provisioned, predictable cost |
| `Standard` | `S0`-`S12` | DTU-based, simplest pricing model |
| `Hyperscale` | `HS_Gen5_4` | Very large databases, fast scaling |

## Diagnostics are per database

Azure SQL emits diagnostic categories (query performance, errors, audits) per database, not at the logical server level — the server itself has no real runtime activity to log. Set `diagnosticsWorkspaceResourceId` once and it applies to every database in `databases`.

## Usage

```bicep
module sqlServer '../../res/sql/server/main.bicep' = {
  name: 'sql'
  params: {
    name: 'sql-orders-001'
    entraAdminLogin: 'sql-admins'
    entraAdminObjectId: sqlAdminsGroupObjectId
    databases: [
      { name: 'orders', skuName: 'GP_S_Gen5_2', skuTier: 'GeneralPurpose' }
    ]
    privateEndpointSubnetResourceId: vnet.outputs.subnetResourceIds[1]
    privateDnsZoneResourceIds: [sqlZone.outputs.resourceId]
  }
}
```

## Tests

- [tests/defaults](tests/defaults/main.test.bicep): serverless database, private endpoint and diagnostics
