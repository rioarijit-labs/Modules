# Azure AI Search

Search service for full-text, vector and hybrid retrieval. Wraps `Azure/avm-res-search-searchservice/azurerm` 0.3.0.

## Defaults

- `basic` tier, one replica, one partition
- Public network access **disabled**, API keys **disabled**: callers use Entra ID
- System-assigned managed identity, so indexers and integrated vectorization can reach storage and Foundry without keys
- Semantic ranker off

## Roles

With API keys disabled, grant data-plane roles through `role_assignments`:

| Role | For |
|---|---|
| `Search Service Contributor` | Managing the service and indexes |
| `Search Index Data Contributor` | Ingestion pipelines writing documents |
| `Search Index Data Reader` | Applications querying the index |

## Notes

- Replica and partition counts multiply cost. Two replicas give read HA, three give read/write HA.
- Switching between tiers is not possible in place: choose the tier for the workload up front.
- The free tier has no private endpoint or managed identity support for most scenarios.

## Usage

```hcl
module "search" {
  source = "../../res/search/search-service"

  name                = "srch-rag-001"
  location            = "westeurope"
  resource_group_id   = azurerm_resource_group.this.id
  semantic_search_sku = "free"

  private_endpoint = {
    subnet_resource_id            = module.network.subnet_resource_ids["private_endpoints"]
    private_dns_zone_resource_ids = [module.search_zone.resource_id]
  }

  role_assignments = {
    app_query = {
      role_definition_id_or_name = "Search Index Data Reader"
      principal_id               = module.app.system_assigned_mi_principal_id
      principal_type             = "ServicePrincipal"
    }
  }
}
```

## Tests

- [tests/defaults](tests/defaults/main.tf): private endpoint with ingestion and query roles
