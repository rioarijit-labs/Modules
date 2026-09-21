# App Service

Secure-by-default web app or function app. Wraps `Azure/avm-res-web-site/azurerm` 0.23.0.

## Defaults

- HTTPS only, TLS 1.2, HTTP/2, FTPS disabled
- Basic publishing credentials (SCM and FTP) **disabled**: deploy with Entra ID
- System-assigned managed identity
- Public network access **disabled**. Reach the app through a private endpoint, or set `public_network_access_enabled` to `true` for an internet-facing app.

## Networking

- **Outbound**: set `virtual_network_subnet_resource_id` to a subnet delegated to `Microsoft.Web/serverFarms` (regional VNet integration).
- **Inbound**: set `private_endpoint` with the `privatelink.azurewebsites.net` zone.

## Usage

```hcl
module "app" {
  source = "../../res/web/app-service"

  name                               = "app-example-001"
  location                           = "westeurope"
  resource_group_id                  = azurerm_resource_group.this.id
  service_plan_resource_id           = module.plan.resource_id
  linux_fx_version                   = "PYTHON|3.12"
  health_check_path                  = "/healthz"
  virtual_network_subnet_resource_id = module.network.subnet_resource_ids["app_integration"]

  app_settings = {
    STORAGE_BLOB_ENDPOINT = module.storage.primary_blob_endpoint
  }
}
```

Put secrets in Key Vault and reference them with `@Microsoft.KeyVault(...)` in `app_settings`.

## Tests

- [tests/defaults](tests/defaults/main.tf): Node app with VNet integration, health check and private endpoint
