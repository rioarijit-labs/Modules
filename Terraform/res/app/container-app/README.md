# Container app

Single-container Container App. Wraps `Azure/avm-res-app-containerapp/azurerm` 0.9.0.

## Defaults

- **Internal ingress**, HTTPS only: reachable only inside the environment. Set `ingress_external_enabled` to `true` to expose it, or `disable_ingress` for workers.
- 0.5 vCPU, 1 GiB, one to three replicas
- System-assigned managed identity
- Secrets are read from **Key Vault** through a managed identity, never passed as plain values

## Pulling from a private registry

Set `registry` with the login `server` and an `identity_resource_id`. The identity must be a **user-assigned managed identity with `AcrPull`** on the registry, and it is attached to the app automatically. A user-assigned identity is used because it exists before the app does; a system-assigned identity is created with the app, so the first revision could not pull.

`registry` is an object rather than two strings so its existence is known at plan time even when the registry is created in the same apply.

## Secrets

```hcl
secrets = {
  "db-connection" = {
    key_vault_secret_id = "https://kv-example.vault.azure.net/secrets/db-connection"
    identity            = azurerm_user_assigned_identity.app.id # needs "Key Vault Secrets User" on the vault
  }
}
env = [
  { name = "DB_CONNECTION", secret_name = "db-connection" },
]
```

The identity that reads a secret must also be attached to the app: add it to `user_assigned_identity_resource_ids` (it is added for you when it is the registry identity).

## Scope

One container per app, and no volumes, probes, Dapr, custom scale rules or custom domains yet. Add them to the module when a use case needs them.

## Usage

```hcl
module "api" {
  source = "../../res/app/container-app"

  name                    = "ca-api-001"
  resource_group_id       = azurerm_resource_group.this.id
  environment_resource_id = module.environment.resource_id
  image                   = "${module.registry.login_server}/api:1.4.2"
  target_port             = 8080

  registry = {
    server               = module.registry.login_server
    identity_resource_id = azurerm_user_assigned_identity.pull.id
  }
}
```

## Tests

- [tests/defaults](tests/defaults/main.tf): private registry pull and a Key Vault secret
