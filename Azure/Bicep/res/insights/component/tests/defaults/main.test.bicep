metadata name = 'Application Insights - defaults'
metadata description = 'Workspace-based component with a shorter retention and sampling for cost control.'

// Placeholder IDs: the test validates the module contract, it does not resolve these resources.
module test '../../main.bicep' = {
  name: 'test-insights-component-defaults'
  params: {
    name: 'appi-defaults'
    logAnalyticsWorkspaceResourceId: '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example/providers/Microsoft.OperationalInsights/workspaces/log-example'
    retentionInDays: 30
    samplingPercentage: 50
  }
}
