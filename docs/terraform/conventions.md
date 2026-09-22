# Conventions

These rules keep the modules predictable for people and for agents. `Azure/Terraform/scripts/validate.py` enforces the mechanical ones. The principles are the same as the [Bicep conventions](../bicep/conventions.md); this page covers what is specific to Terraform.

## Structure

- One module per folder: `res/<provider>/<module>/`, named after the resource, not the AVM module. The folder path is the module ID (`azure:terraform:res/storage/storage-account`) and matches the Bicep module of the same name.
- Files: `main.tf`, `variables.tf`, `outputs.tf`, `versions.tf`, `module.json`, `README.md`, and at least `tests/defaults/main.tf`.
- `res` wraps one primary resource. `ptn` composes `res` modules.

## Wrapping AVM

- Reference AVM from the registry with an **exact** version: `source = "Azure/avm-res-.../azurerm"` and `version = "x.y.z"`. No ranges.
- The `wraps.version` in `module.json` must match `main.tf` (checked by the validator). Keep `source` and `version` on adjacent lines in that order, as `terraform fmt` aligns them.
- Expose a small typed surface, not every AVM variable. Add a variable when a real use case needs it.
- Set secure values in the wrapper explicitly, even when the upstream default is already secure, so an upstream change cannot weaken them.

## Variables

Use these names for the same concept in every module:

| Concept | Variable | Notes |
|---|---|---|
| Resource name | `name` | First variable |
| Region | `location` | Required. No default: Terraform has no ambient resource group |
| Resource group | `resource_group_id` | Full resource ID, e.g. `azurerm_resource_group.this.id`. The name is derived from it where a module needs it |
| Tags | `tags` | `map(string)`, default `{}` |
| Log Analytics workspace | `diagnostics` | `object({ workspace_resource_id })`, default `null` |
| Private endpoint | `private_endpoint` | `object({ subnet_resource_id, private_dns_zone_resource_ids })`, default `null` |
| Public access | `public_network_access_enabled` | Default `false` |
| Identity | `enable_system_assigned_identity`, `user_assigned_identity_resource_ids` | |
| RBAC | `role_assignments` | `map(object({ role_definition_id_or_name, principal_id, principal_type, description }))` |

### Why optional features are objects, not empty strings

Terraform decides which resources exist at plan time. If a module receives `private_endpoint_subnet_resource_id = azurerm_subnet.x.id` and the subnet is created in the same apply, that string is unknown, so `var.x == ""` is unknown and the `for_each` over private endpoints fails. A nullable **object** solves it: `var.private_endpoint != null` is known even when `subnet_resource_id` inside it is not. Use the same pattern for any optional feature that creates resources (`diagnostics`, `registry`, `network_security_group`).

For the same reason, collections that become resource keys (`container_names`, `virtual_network_resource_ids`, `queues`) are maps or sets keyed by **static** names you write in code, not by IDs that only exist after apply.

### Rules

- Every `variable` and `output` has a `description`. Say what it is, the unit or format, and what null or empty means.
- Use `validation` blocks wherever a wrong value would fail late in deployment (allowed values, ranges, name patterns).
- Prefer object types with `optional(...)` attributes over `any` and bare `map(any)`.
- Mark secrets `sensitive = true`. Never output secrets. Never generate a credential and keep it only in state unless the module says so and explains why.
- Outputs return values a caller would wire into another module: `resource_id`, `name`, and service-specific ones such as `endpoint` or `subnet_resource_ids`.

## Providers

- `versions.tf` sets `required_version = ">= 1.11, < 2.0"` and lists the providers the module (or the AVM module it wraps) needs, with a compatible `~>` constraint.
- Wrappers never contain `provider` blocks. The root module configures them (`azurerm` needs `features {}`).
- Test cases include a `provider "azurerm" { features {} }` block when the module needs `azurerm`.

## Secure defaults

| Area | Default |
|---|---|
| Network | Public network access disabled; private endpoint supported |
| Authentication | Entra ID only: shared keys, local auth, FTP and basic publishing credentials disabled |
| Transport | HTTPS only, TLS 1.2 minimum |
| Data protection | Soft delete on where supported |
| Firewall | Default action `Deny`, `AzureServices` bypass |
| NSG | Explicit deny-all inbound rule at priority 4096 |
| Monitoring | Diagnostic settings to Log Analytics when `diagnostics` is set |

If a module deliberately deviates, say why in its README.

## Versioning and releases

- Releases are tagged for the whole Terraform folder: `azure-terraform/v<major>.<minor>.<patch>`. The `azure-` prefix distinguishes it from a future `aws-terraform/v...` tag namespace, since Terraform (unlike Bicep) spans both clouds.
- Callers pin to a tag or commit SHA in the module `source` (`?ref=azure-terraform/v0.1.0`).
- Breaking changes (renamed or removed variables, changed defaults) bump the major version once the repo reaches 1.0.
- Bump the AVM version deliberately: read the AVM changelog, update `main.tf` and `module.json` together, run the validator.

## Testing

`terraform validate` (run by the validator on every test case) checks argument names, types and `validation` blocks. It does not plan or apply. Real deployment testing, with `terraform plan` at least, needs an Azure subscription and belongs in a separate environment repository.
