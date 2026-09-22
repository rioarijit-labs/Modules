metadata name = 'Front Door - defaults'
metadata description = 'Standard profile routing to an App Service origin, with a custom domain.'

module test '../../main.bicep' = {
  name: 'test-cdn-profile-defaults'
  params: {
    name: 'afd-defaults'
    origins: [
      {
        name: 'app-origin'
        hostName: 'app-example-001.azurewebsites.net'
      }
    ]
    healthProbePath: '/healthz'
    customDomainNames: ['www.example.com']
  }
}
