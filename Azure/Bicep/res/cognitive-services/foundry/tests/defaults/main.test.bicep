metadata name = 'Foundry - defaults'
metadata description = 'Foundry resource with one model deployment and one project, Entra ID only, no public access.'

module test '../../main.bicep' = {
  name: 'test-foundry-defaults'
  params: {
    name: 'aif-defaults-${uniqueString(resourceGroup().id)}'
    modelDeployments: [
      {
        name: 'gpt-4o'
        model: {
          format: 'OpenAI'
          name: 'gpt-4o'
          version: '2024-11-20'
        }
        sku: {
          name: 'GlobalStandard'
          capacity: 10
        }
      }
    ]
    projects: [
      {
        name: 'proj-default'
        displayName: 'Default project'
        description: 'Project created by the module test.'
      }
    ]
  }
}
