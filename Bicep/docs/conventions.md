# Conventions

These rules keep the modules predictable for people and for agents. `scripts/validate.py` enforces the mechanical ones.

## Structure

- One module per folder: `res/<provider>/<module>/main.bicep`, named after the resource, not the AVM module. The folder path is the module ID (`bicep:res/storage/storage-account`).
- `res` wraps one primary resource. `ptn` composes `res` modules. `utl` holds shared types and helpers.
- Every module has `module.json`, a `README.md` and at least `tests/defaults/main.test.bicep`.

## Wrapping AVM

- Reference AVM as `br/public:avm/...` with an **exact** version. No ranges, no `latest`.
- The `wraps.version` in `module.json` must match `main.bicep` (checked by the validator).
- Expose a small typed surface, not every AVM parameter. Add a parameter when a real use case needs it.
- Set secure values in the wrapper and let the caller relax them explicitly.

## Parameters

Use these names for the same concept in every module:

| Concept | Parameter | Notes |
|---|---|---|
| Resource name | `name` | First parameter |
| Region | `location` | Default `resourceGroup().location` |
| Tags | `tags` | Default `{}` |
| Log Analytics workspace | `diagnosticsWorkspaceResourceId` | Empty string means no diagnostics |
| Private endpoint subnet | `privateEndpointSubnetResourceId` | Empty string means no private endpoint |
| Private DNS zones | `privateDnsZoneResourceIds` | Array (or object keyed by service for storage) |
| Public access | `publicNetworkAccess` | Default `Disabled` |
| Identity | `enableSystemAssignedIdentity`, `userAssignedIdentityResourceIds` | |
| RBAC | `roleAssignments` | Type from `utl/types` |

- Every `param` and `output` has `@description`. Say what it is, the unit or format, and what empty means.
- Use `@allowed`, `@minLength`, `@maxLength`, `@minValue` and `@maxValue` wherever a wrong value would fail late in deployment.
- Prefer user-defined types over `object` and `array`. Export types other modules or callers need with `@export()`.
- Never take secrets as plain parameters. Use `@secure()` or Key Vault references. Never output secrets.

## Secure defaults

| Area | Default |
|---|---|
| Network | Public network access disabled; private endpoint supported |
| Authentication | Entra ID only: shared keys, local auth, FTP and basic publishing credentials disabled |
| Transport | HTTPS only, TLS 1.2 minimum |
| Data protection | Soft delete on where supported |
| Firewall | Default action `Deny`, `AzureServices` bypass |
| NSG | Explicit deny-all inbound rule at priority 4096 |
| Monitoring | Diagnostic settings to Log Analytics when a workspace is given |

If a module deliberately deviates, say why in its README.

## Versioning and releases

- Releases are tagged for the whole Bicep folder: `bicep/v<major>.<minor>.<patch>`.
- Callers pin to a tag or commit SHA.
- Breaking changes (renamed or removed parameters, changed defaults) bump the major version once the repo reaches 1.0.
- Bump the AVM version deliberately: read the AVM changelog, update `main.bicep` and `module.json` together, run the validator.
