# User-assigned managed identity

Standalone identity, reusable across resources or federated with an external OIDC issuer. Wraps `br/public:avm/res/managed-identity/user-assigned-identity:0.6.0`.

## Why a user-assigned identity instead of system-assigned

- **It exists before the resource that uses it.** A Container App's registry pull identity, for example, must exist and hold `AcrPull` before the app's first revision can pull an image — a system-assigned identity is created with the app, too late.
- **One identity, several resources.** Useful when multiple Container Apps or VMs should share the same permission set.
- **Federated credentials (no secret).** Trust tokens from Kubernetes (AKS workload identity) or GitHub Actions OIDC directly, with no client secret to rotate.

## Usage

```bicep
module pullIdentity '../../res/managed-identity/user-assigned-identity/main.bicep' = {
  name: 'pull-identity'
  params: {
    name: 'id-acr-pull'
    roleAssignments: [
      {
        roleDefinitionIdOrName: 'AcrPull'
        principalId: /* resolved after the fact via principalId output, or scope elsewhere */ ''
      }
    ]
  }
}
```

For GitHub Actions OIDC login (no secret in the workflow):

```bicep
federatedIdentityCredentials: [
  {
    name: 'github-actions'
    issuer: 'https://token.actions.githubusercontent.com'
    subject: 'repo:my-org/my-repo:ref:refs/heads/main'
    audiences: []
  }
]
```

## Tests

- [tests/defaults](tests/defaults/main.test.bicep): AKS workload identity and GitHub Actions federated credentials
