metadata name = 'Container app - defaults'
metadata description = 'Internal API pulling from a private registry with a managed identity and reading a secret from Key Vault.'

// Placeholder IDs: the test validates the module contract, it does not resolve these resources.
var pullIdentityResourceId = '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example/providers/Microsoft.ManagedIdentity/userAssignedIdentities/id-acr-pull'

module test '../../main.bicep' = {
  name: 'test-container-app-defaults'
  params: {
    name: 'ca-defaults'
    environmentResourceId: '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example/providers/Microsoft.App/managedEnvironments/cae-example'
    image: 'acrexample.azurecr.io/api:1.0.0'
    registryServer: 'acrexample.azurecr.io'
    registryIdentityResourceId: pullIdentityResourceId
    targetPort: 8080
    minReplicas: 1
    maxReplicas: 5
    secrets: [
      {
        name: 'db-connection'
        keyVaultUrl: 'https://kv-example${environment().suffixes.keyvaultDns}/secrets/db-connection'
        identity: pullIdentityResourceId
      }
    ]
    env: [
      { name: 'ASPNETCORE_ENVIRONMENT', value: 'Production' }
      { name: 'DB_CONNECTION', secretRef: 'db-connection' }
    ]
  }
}
