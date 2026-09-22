# User-assigned managed identity

Standalone identity, reusable across resources or federated with an external OIDC issuer. Wraps `Azure/avm-res-managedidentity-userassignedidentity/azurerm` 0.5.2.

## `role_assignments` works backwards here

Every other module in this repo grants a role **on that resource, to some principal you name** (`principal_id`). This module is the opposite: the principal is always the identity itself, and you say **where** the role applies (`scope`) — there is no `principal_id` field at all.

```hcl
role_assignments = {
  storage_contributor = {
    role_definition_id_or_name = "Storage Blob Data Contributor"
    scope                       = azurerm_storage_account.this.id
  }
}
```

## Why a user-assigned identity instead of system-assigned

- **It exists before the resource that uses it.** A Container App's registry pull identity, for example, must exist and hold `AcrPull` before the app's first revision can pull an image — a system-assigned identity is created with the app, too late.
- **One identity, several resources.** Useful when multiple Container Apps or VMs should share the same permission set.
- **Federated credentials (no secret).** Trust tokens from Kubernetes (AKS workload identity) or GitHub Actions OIDC directly, with no client secret to rotate.

## Usage

```hcl
module "pull_identity" {
  source = "../../res/managed-identity/user-assigned-identity"

  name              = "id-acr-pull"
  location          = "westeurope"
  resource_group_id = azurerm_resource_group.this.id

  role_assignments = {
    acr_pull = {
      role_definition_id_or_name = "AcrPull"
      scope                       = module.registry.resource_id
    }
  }
}
```

For GitHub Actions OIDC login (no secret in the workflow):

```hcl
federated_identity_credentials = {
  github_actions = {
    issuer    = "https://token.actions.githubusercontent.com"
    subject   = "repo:my-org/my-repo:ref:refs/heads/main"
    audiences = []
  }
}
```

## Tests

- [tests/defaults](tests/defaults/main.tf): AKS workload identity and GitHub Actions federated credentials
