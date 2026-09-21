metadata name = 'App Service plan - defaults'
metadata description = 'Linux P1v3 plan with one instance.'

module test '../../main.bicep' = {
  name: 'test-app-service-plan-defaults'
  params: {
    name: 'asp-defaults'
  }
}
