metadata name = 'User-assigned managed identity - defaults'
metadata description = 'Identity federated for AKS workload identity and GitHub Actions OIDC.'

module test '../../main.bicep' = {
  name: 'test-user-assigned-identity-defaults'
  params: {
    name: 'id-defaults'
    federatedIdentityCredentials: [
      {
        name: 'aks-workload-identity'
        issuer: 'https://westeurope.oic.prod-aks.azure.com/00000000-0000-0000-0000-000000000000/00000000-0000-0000-0000-000000000000/'
        subject: 'system:serviceaccount:default:my-app'
        audiences: []
      }
      {
        name: 'github-actions'
        issuer: 'https://token.actions.githubusercontent.com'
        subject: 'repo:example/repo:ref:refs/heads/main'
        audiences: []
      }
    ]
  }
}
