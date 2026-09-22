# Container registry

Azure Container Registry. Wraps `Azure/avm-res-containerregistry-registry/azurerm` 0.8.0.

## Defaults

- **Premium** tier, zone redundant: required for private endpoints and the firewall
- Public network access **disabled**, firewall default action `Deny`, `AzureServices` bypass
- Admin user **disabled**, anonymous pull **disabled**: use Entra ID and roles
- Export from the registry disabled

## Roles

| Role | For |
|---|---|
| `AcrPull` | Container Apps, AKS, App Service pulling images |
| `AcrPush` | CI/CD pushing images |

## Notes

- With public access disabled, pushing from a hosted CI runner fails. Use a self-hosted runner in the VNet, ACR Tasks, or set `public_network_access_enabled` to `true` with a firewall rule for the runner.
- Basic and Standard have no private endpoint. For a cheap lab, set `sku_name` to `Basic` and `public_network_access_enabled` to `true`.

## Usage

```hcl
module "registry" {
  source = "../../res/container-registry/registry"

  name              = "acrexample001"
  location          = "westeurope"
  resource_group_id = azurerm_resource_group.this.id

  private_endpoint = {
    subnet_resource_id            = module.network.subnet_resource_ids["private_endpoints"]
    private_dns_zone_resource_ids = [module.acr_zone.resource_id]
  }

  role_assignments = {
    workload_pull = {
      role_definition_id_or_name = "AcrPull"
      principal_id               = azurerm_user_assigned_identity.pull.principal_id
      principal_type             = "ServicePrincipal"
    }
  }
}
```

## Tests

- [tests/defaults](tests/defaults/main.tf): private endpoint and an AcrPull assignment
