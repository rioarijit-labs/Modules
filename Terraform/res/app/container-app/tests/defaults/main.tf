# Internal API pulling from a private registry with a managed identity and reading a secret from Key Vault.
# Placeholder IDs: the test validates the module contract, it does not resolve these resources.
locals {
  pull_identity_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example/providers/Microsoft.ManagedIdentity/userAssignedIdentities/id-acr-pull"
}

module "test" {
  source = "../../"

  name                    = "ca-defaults"
  resource_group_id       = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example"
  environment_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example/providers/Microsoft.App/managedEnvironments/cae-example"
  image                   = "acrexample.azurecr.io/api:1.0.0"
  target_port             = 8080
  min_replicas            = 1
  max_replicas            = 5

  registry = {
    server               = "acrexample.azurecr.io"
    identity_resource_id = local.pull_identity_resource_id
  }

  secrets = {
    "db-connection" = {
      key_vault_secret_id = "https://kv-example.vault.azure.net/secrets/db-connection"
      identity            = local.pull_identity_resource_id
    }
  }

  env = [
    { name = "ASPNETCORE_ENVIRONMENT", value = "Production" },
    { name = "DB_CONNECTION", secret_name = "db-connection" },
  ]
}
