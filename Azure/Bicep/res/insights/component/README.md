# Application Insights

Workspace-based Application Insights component. Wraps `br/public:avm/res/insights/component:0.8.0`.

## Defaults

- Workspace-based only (classic standalone Application Insights is retired by Microsoft; `logAnalyticsWorkspaceResourceId` is required)
- 90 day retention, 100% sampling (no data dropped)
- Public ingestion and query **enabled**, matching the same deliberate exception as the [log-analytics-workspace](../../operational-insights/log-analytics-workspace) module: disabling either requires an Azure Monitor Private Link Scope, otherwise telemetry silently stops arriving

## Notes

- Set `retentionInDays` and `samplingPercentage` down on high-volume apps to control cost; sampling below 100% means some traces are dropped, which affects rare-event debugging.
- `connectionString` is the value an app's SDK needs (`APPLICATIONINSIGHTS_CONNECTION_STRING`). It identifies the ingestion endpoint; it is not itself sufficient to read data back out.
- `disableLocalAuth` turns off API-key based ingestion; use it once your apps send telemetry with Entra ID authenticated OpenTelemetry exporters.

## Usage

```bicep
module appInsights '../../res/insights/component/main.bicep' = {
  name: 'app-insights'
  params: {
    name: 'appi-example-001'
    logAnalyticsWorkspaceResourceId: logs.outputs.resourceId
  }
}

module app '../../res/web/app-service/main.bicep' = {
  name: 'app'
  params: {
    // ...
    appSettings: {
      APPLICATIONINSIGHTS_CONNECTION_STRING: appInsights.outputs.connectionString
    }
  }
}
```

## Tests

- [tests/defaults](tests/defaults/main.test.bicep): shorter retention and 50% sampling for cost control
