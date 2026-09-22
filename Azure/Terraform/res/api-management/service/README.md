# API Management

Azure API Management gateway. Wraps `Azure/avm-res-apimanagement-service/azurerm` 0.9.0.

## Defaults

- **Developer** SKU — no SLA, no VNet integration, but inexpensive; deliberately different from the AVM module's own default (Premium) since most non-production and showcase deployments don't need Premium's cost. Set `sku` explicitly for production (e.g. `"Premium_1"` or `"StandardV2_1"`).
- System-assigned managed identity, for Key Vault-backed named values and certificates
- `public_network_access_enabled = true` by default — only Premium/PremiumV2 support disabling it behind a private endpoint

## SKU and networking

Only Premium and the newer StandardV2/PremiumV2 SKUs support VNet integration (`virtual_network_type`) and private endpoints. Developer, Basic and Standard are always publicly reachable at `<name>.azure-api.net`; for those tiers, use APIM's own IP restriction/CORS policies rather than network isolation.

## APIs

`apis` imports APIs from an OpenAPI specification URL, keyed by an arbitrary static name. For anything beyond a straight OpenAPI import (policies, product/subscription grouping, custom operations), manage those APIM sub-resources with native `azurerm_api_management_*` resources alongside this module — this module intentionally keeps the gateway resource itself simple.

## Usage

```hcl
module "apim" {
  source = "../../res/api-management/service"

  name                = "apim-orders-001"
  location            = "westeurope"
  resource_group_id   = azurerm_resource_group.this.id
  publisher_name      = "Contoso"
  publisher_email     = "api-team@contoso.com"

  apis = {
    orders = {
      display_name      = "Orders API"
      path               = "orders"
      open_api_spec_url  = "https://raw.githubusercontent.com/contoso/orders-api/main/openapi.yaml"
    }
  }
}
```

## Tests

- [tests/defaults](tests/defaults/main.tf): Developer SKU with one imported API
