# Storage account

Secure-by-default storage account. Wraps `Azure/avm-res-storage-storageaccount/azurerm` 0.10.0.

## Defaults

- Public network access **disabled**, firewall default action `Deny`
- Shared key access and anonymous blob access **disabled**, Entra ID is the default authentication
- HTTPS only, TLS 1.2
- Blob and container soft delete, 7 days
- Zone-redundant (`Standard_ZRS`)

Data plane access needs a private endpoint: set `private_endpoint`. To reach the account publicly, set `public_network_access_enabled` to `true` and add firewall rules deliberately.

## Usage

```hcl
module "storage" {
  source = "../../res/storage/storage-account"

  name              = "stexample001"
  location          = "westeurope"
  resource_group_id = azurerm_resource_group.this.id
  container_names   = ["raw", "curated"]

  private_endpoint = {
    subnet_resource_id = module.network.subnet_resource_ids["private_endpoints"]
    private_dns_zone_resource_ids = {
      blob = module.blob_zone.resource_id
    }
  }

  role_assignments = {
    app_blob_contributor = {
      role_definition_id_or_name = "Storage Blob Data Contributor"
      principal_id               = module.app.system_assigned_mi_principal_id
      principal_type             = "ServicePrincipal"
    }
  }
}
```

## Notes

- `container_names` must be known at plan time (literals or variables), because they become map keys.
- Diagnostics send account-level metrics. Blob, file, queue and table service logs are not enabled yet.

## Tests

- [tests/defaults](tests/defaults/main.tf): secure defaults only
- [tests/private](tests/private/main.tf): data lake with blob and dfs private endpoints and diagnostics
