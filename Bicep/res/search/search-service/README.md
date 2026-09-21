# Azure AI Search

Search service for full-text, vector and hybrid retrieval. Wraps `br/public:avm/res/search/search-service:0.13.0`.

## Defaults

- `basic` tier, one replica, one partition
- Public network access **disabled**, API keys **disabled**: callers use Entra ID
- System-assigned managed identity, so indexers and integrated vectorization can reach storage and Foundry without keys
- Semantic ranker off

## Roles

With API keys disabled, grant data-plane roles through `roleAssignments`:

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

```bicep
module search '../../res/search/search-service/main.bicep' = {
  name: 'search'
  params: {
    name: 'srch-rag-001'
    semanticSearch: 'free'
    privateEndpointSubnetResourceId: vnet.outputs.subnetResourceIds[1]
    privateDnsZoneResourceIds: [searchZone.outputs.resourceId]
    roleAssignments: [
      {
        roleDefinitionIdOrName: 'Search Index Data Reader'
        principalId: app.outputs.systemAssignedMIPrincipalId
        principalType: 'ServicePrincipal'
      }
    ]
  }
}
```

## Tests

- [tests/defaults](tests/defaults/main.test.bicep): private endpoint with ingestion and query roles
