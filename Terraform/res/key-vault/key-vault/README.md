# Key Vault

Secure-by-default Key Vault. Wraps `Azure/avm-res-keyvault-vault/azurerm` 0.11.0.

## Defaults

- **Azure RBAC** for authorization, no legacy access policies
- Soft delete (90 days) and **purge protection** on
- Public network access **disabled**, firewall default action `Deny`
- `standard` SKU (the upstream module defaults to `premium`)
- The tenant ID is read from the `azurerm` provider configuration

## Notes

- **Purge protection cannot be turned off**, and a deleted vault keeps its name reserved for the retention period. For throwaway lab deployments, set `purge_protection_enabled` to false and use a unique name.
- The deploying identity needs a data-plane role (for example `Key Vault Secrets Officer`) to create secrets. This module creates no secrets: set them from a pipeline or reference them from other services.
- Grant apps `Key Vault Secrets User` through `role_assignments`. Container Apps and App Service can then use Key Vault references, with no secret values in Terraform.

## Usage

```hcl
module "key_vault" {
  source = "../../res/key-vault/key-vault"

  name              = "kv-example-001"
  location          = "westeurope"
  resource_group_id = azurerm_resource_group.this.id

  private_endpoint = {
    subnet_resource_id            = module.network.subnet_resource_ids["private_endpoints"]
    private_dns_zone_resource_ids = [module.key_vault_zone.resource_id]
  }

  role_assignments = {
    app_secrets_user = {
      role_definition_id_or_name = "Key Vault Secrets User"
      principal_id               = module.app.system_assigned_mi_principal_id
      principal_type             = "ServicePrincipal"
    }
  }
}
```

## Tests

- [tests/defaults](tests/defaults/main.tf): private endpoint, diagnostics and a secrets reader role
