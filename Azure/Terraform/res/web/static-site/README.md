# Static Web App

Static Web App for a frontend, SPA or documentation site, with a managed global CDN. Wraps `Azure/avm-res-web-staticsite/azurerm` 0.6.2.

## Defaults deliberately differ from the rest of this repo

Every other module in this repo defaults `public_network_access_enabled` to `false`. This one defaults it to `true`, because a static site is usually built specifically to be reached over the public internet — the managed CDN and custom domains both assume that. Set `public_network_access_enabled` to `false` and provide `private_endpoint` for an internal-only site (Standard SKU only).

## Other defaults

- `Standard` SKU (Free has no private endpoint and no support SLA)
- System-assigned managed identity **off** by default (most static sites don't call other Azure resources); turn it on if API functions need it

## No native source control integration

Unlike the Bicep flavor of this module, this Terraform wrapper does not expose repository/branch/token inputs at all. The upstream `avm-res-web-staticsite` module (0.6.2) doesn't take a repository token, so wiring the resource's own GitHub/DevOps CI/CD would be incomplete here. Deploy content separately instead, with the [SWA CLI](https://azure.github.io/static-web-apps-cli/) or a GitHub Actions step, using the app's deployment token — fetched at deploy time (`az staticwebapp secrets list`), never stored as a Terraform variable or output. The underlying resource does have an `api_key` attribute, but this module does not surface it, consistent with never outputting secrets.

## Usage

```hcl
module "site" {
  source = "../../res/web/static-site"

  name              = "swa-docs-001"
  location          = "westeurope"
  resource_group_id = azurerm_resource_group.this.id

  custom_domain_names = ["docs.example.com"]

  app_settings = {
    API_BASE_URL = "https://api.example.com"
  }
}
```

For an internal-only app:

```hcl
public_network_access_enabled = false
private_endpoint = {
  subnet_resource_id            = module.network.subnet_resource_ids["private_endpoints"]
  private_dns_zone_resource_ids = [module.swa_zone.resource_id]
}
```

## Tests

- [tests/defaults](tests/defaults/main.tf): public app with a custom domain and app settings
- [tests/private](tests/private/main.tf): internal-only app with a private endpoint
