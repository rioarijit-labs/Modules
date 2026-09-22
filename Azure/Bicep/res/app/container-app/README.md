# Container app

Single-container Container App. Wraps `br/public:avm/res/app/container-app:0.23.0`.

## Defaults

- **Internal ingress**, HTTPS only: reachable only inside the environment. Set `ingressExternal` to `true` to expose it, or `disableIngress` for workers.
- 0.5 vCPU, 1 GiB, one to three replicas
- System-assigned managed identity
- Secrets are read from **Key Vault** through a managed identity, never passed as plain values

## Pulling from a private registry

Set `registryServer` and `registryIdentityResourceId`. The identity must be a **user-assigned managed identity with `AcrPull`** on the registry. A user-assigned identity is used because it exists before the app does; a system-assigned identity is created with the app, so the first revision could not pull.

## Secrets

```bicep
secrets: [
  {
    name: 'db-connection'
    keyVaultUrl: 'https://kv-example.vault.azure.net/secrets/db-connection'
    identity: pullIdentityResourceId   // needs "Key Vault Secrets User" on the vault
  }
]
env: [
  { name: 'DB_CONNECTION', secretRef: 'db-connection' }
]
```

## Scope

One container per app, and no volumes, probes, Dapr, custom scale rules or custom domains yet. Add them to the module when a use case needs them.

## Usage

```bicep
module api '../../res/app/container-app/main.bicep' = {
  name: 'api'
  params: {
    name: 'ca-api-001'
    environmentResourceId: environment.outputs.resourceId
    image: '${registry.outputs.loginServer}/api:1.4.2'
    registryServer: registry.outputs.loginServer
    registryIdentityResourceId: pullIdentityResourceId
    targetPort: 8080
  }
}
```

## Tests

- [tests/defaults](tests/defaults/main.test.bicep): private registry pull and a Key Vault secret
