# Log Analytics workspace

Workspace that receives diagnostic logs and metrics. Wraps `Azure/avm-res-operationalinsights-workspace/azurerm` 0.5.1.

## Defaults

- `PerGB2018` pricing, 30 day retention, no daily cap
- Public ingestion and query **enabled**. This is a deliberate exception to the private-by-default rule in [conventions](../../../docs/conventions.md), and it differs from the upstream module default: turning public ingestion off without an Azure Monitor Private Link Scope silently stops logs from every resource that sends here. Disable it only when you also deploy the scope.

## Notes

- Create one workspace per environment or one central workspace, then pass its `resource_id` as `diagnostics = { workspace_resource_id = ... }` to the other modules.
- A daily cap (`daily_quota_gb`) protects cost in a lab but drops data once reached. Leave it at `-1` for anything you monitor.

## Usage

```hcl
module "logs" {
  source = "../../res/operational-insights/log-analytics-workspace"

  name              = "log-platform-001"
  location          = "westeurope"
  resource_group_id = azurerm_resource_group.this.id
  retention_in_days = 90
}

module "storage" {
  source = "../../res/storage/storage-account"

  name              = "stexample001"
  location          = "westeurope"
  resource_group_id = azurerm_resource_group.this.id
  diagnostics       = { workspace_resource_id = module.logs.resource_id }
}
```

## Tests

- [tests/defaults](tests/defaults/main.tf): default workspace with a 1 GB daily cap
