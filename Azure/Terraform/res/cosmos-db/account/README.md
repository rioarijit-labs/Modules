# Cosmos DB account

Cosmos DB account using the SQL (Core) API, with databases and containers. Wraps `Azure/avm-res-documentdb-databaseaccount/azurerm` 0.11.0.

## Defaults

- Public network access **disabled**, firewall bypass for trusted Azure services only
- API keys **disabled** (`local_authentication_disabled` is always on): callers use Entra ID through the account's **own** RBAC system, not Azure RBAC
- `Session` consistency, provisioned capacity, `Continuous` backup (point-in-time restore)
- Single region, no zone redundancy (cheap default; opt into `zone_redundant` and `additional_locations` for production)

## Two separate RBAC systems — don't confuse them

Cosmos DB has its own data-plane RBAC, independent of Azure RBAC:

| Variable | Governs | Example role |
|---|---|---|
| `role_assignments` | Azure RBAC, **management operations only** (create/list/delete the account) | `Cosmos DB Account Reader Role` |
| `data_role_assignments` | Cosmos DB's own RBAC, **reading and writing data** | `Reader`, `Contributor` |

Because API keys are always disabled, an application with `Contributor` on the account via `role_assignments` still **cannot read a single document** until it also has an entry in `data_role_assignments`.

## An upstream gap this module fills in

The upstream `avm-res-documentdb-databaseaccount` module (0.11.0) does not yet create Cosmos DB's own SQL role assignments, only Azure RBAC ones. Since API keys are permanently disabled, a wrapper with no way to grant data access would be useless, so this module creates `azurerm_cosmosdb_sql_role_assignment` resources directly, outside the AVM module, using Cosmos DB's documented built-in role IDs (`00000000-...0001` for Reader, `...0002` for Contributor). This mirrors the Bicep flavor, where the equivalent AVM module already supports it natively.

```hcl
data_role_assignments = {
  app_contributor = {
    principal_id = module.app.system_assigned_mi_principal_id
    role         = "Contributor"
  }
}
```

## Capacity mode

- Provisioned (default): reserve RU/s per container or database. Predictable cost, right for steady traffic.
- `serverless = true`: pay per request, capped at 5000 RU/s total and incompatible with `free_tier_enabled` or per-item throughput. Cheaper for spiky, low-traffic or dev workloads.

## Multi-region

`location` is always the primary (write) region. Add `additional_locations` (read regions) and set `enable_automatic_failover` to promote one automatically if the primary fails. Multi-region roughly multiplies write cost by the number of regions.

## Usage

```hcl
module "cosmos" {
  source = "../../res/cosmos-db/account"

  name              = "cosmos-catalog-001"
  location          = "westeurope"
  resource_group_id = azurerm_resource_group.this.id

  sql_databases = {
    catalog = {
      throughput = 400
      containers = {
        products = {
          partition_key_paths = ["/category"]
        }
      }
    }
  }

  private_endpoint = {
    subnet_resource_id            = module.network.subnet_resource_ids["private_endpoints"]
    private_dns_zone_resource_ids = [module.cosmos_zone.resource_id]
  }

  data_role_assignments = {
    app = {
      principal_id = module.app.system_assigned_mi_principal_id
      role         = "Contributor"
    }
  }
}
```

## Tests

- [tests/defaults](tests/defaults/main.tf): single database, shared throughput, a reader data role
- [tests/private](tests/private/main.tf): serverless, a second read region, private endpoint and diagnostics
