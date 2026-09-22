metadata name = 'Static Web App - defaults'
metadata description = 'Public Standard-tier app with a custom domain and app settings, no source control integration.'

module test '../../main.bicep' = {
  name: 'test-static-site-defaults'
  params: {
    name: 'swa-defaults-${take(uniqueString(resourceGroup().id), 8)}'
    customDomainNames: ['www.example.com']
    appSettings: {
      API_BASE_URL: 'https://api.example.com'
    }
  }
}
