# Application Insights

Workspace-based Application Insights component. Wraps `Azure/avm-res-insights-component/azurerm` 0.4.0.

## Defaults

- Workspace-based only (classic standalone Application Insights is retired by Microsoft; `log_analytics_workspace_id` is required)
- 90 day retention, 100% sampling (no data dropped)
- Public ingestion and query **enabled**, matching the same deliberate exception as the [log-analytics-workspace](../../operational-insights/log-analytics-workspace) module: disabling either requires an Azure Monitor Private Link Scope, otherwise telemetry silently stops arriving

## Notes

- Set `retention_in_days` and `sampling_percentage` down on high-volume apps to control cost; sampling below 100% means some traces are dropped, which affects rare-event debugging.
- `connection_string` is the value an app's SDK needs (`APPLICATIONINSIGHTS_CONNECTION_STRING`). It identifies the ingestion endpoint; it is not itself sufficient to read data back out.
- `local_authentication_disabled` turns off API-key based ingestion; use it once your apps send telemetry with Entra ID authenticated OpenTelemetry exporters.

## Usage

```hcl
module "app_insights" {
  source = "../../res/insights/component"

  name                        = "appi-example-001"
  location                    = "westeurope"
  resource_group_id           = azurerm_resource_group.this.id
  log_analytics_workspace_id  = module.logs.resource_id
}
```

## Tests

- [tests/defaults](tests/defaults/main.tf): shorter retention and 50% sampling for cost control
