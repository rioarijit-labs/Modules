metadata name = 'Log Analytics workspace - defaults'
metadata description = 'Pay-as-you-go workspace with 30 day retention and a 1 GB daily cap.'

module test '../../main.bicep' = {
  name: 'test-log-analytics-workspace-defaults'
  params: {
    name: 'log-defaults'
    dailyQuotaGb: '1'
  }
}
