# Log Analytics workspace

Workspace that receives diagnostic logs and metrics. Wraps `br/public:avm/res/operational-insights/workspace:0.16.1`.

## Defaults

- `PerGB2018` pricing, 30 day retention, no daily cap
- Public ingestion and query **enabled**. This is a deliberate exception to the private-by-default rule in [conventions](../../../docs/conventions.md): turning public ingestion off without an Azure Monitor Private Link Scope silently stops logs from every resource that sends here. Disable it only when you also deploy the scope.

## Notes

- Create one workspace per environment or one central workspace, then pass its `resourceId` as `diagnosticsWorkspaceResourceId` to the other modules.
- A daily cap (`dailyQuotaGb`) protects cost in a lab but drops data once reached. Leave it at `-1` for anything you monitor.

## Usage

```bicep
module logs '../../res/operational-insights/log-analytics-workspace/main.bicep' = {
  name: 'logs'
  params: {
    name: 'log-platform-001'
    retentionInDays: 90
  }
}

module storage '../../res/storage/storage-account/main.bicep' = {
  name: 'storage'
  params: {
    name: 'stexample001'
    diagnosticsWorkspaceResourceId: logs.outputs.resourceId
  }
}
```

## Tests

- [tests/defaults](tests/defaults/main.test.bicep): default workspace with a 1 GB daily cap
