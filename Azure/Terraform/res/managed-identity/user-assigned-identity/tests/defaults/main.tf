# Identity federated for AKS workload identity and GitHub Actions OIDC.
provider "azurerm" {
  features {}
}

module "test" {
  source = "../../"

  name              = "id-defaults"
  location          = "westeurope"
  resource_group_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example"

  federated_identity_credentials = {
    aks_workload_identity = {
      issuer    = "https://westeurope.oic.prod-aks.azure.com/00000000-0000-0000-0000-000000000000/00000000-0000-0000-0000-000000000000/"
      subject   = "system:serviceaccount:default:my-app"
      audiences = []
    }
    github_actions = {
      issuer    = "https://token.actions.githubusercontent.com"
      subject   = "repo:example/repo:ref:refs/heads/main"
      audiences = []
    }
  }
}
