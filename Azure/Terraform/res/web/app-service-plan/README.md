# App Service plan

Compute plan for App Service web apps and function apps. Wraps `Azure/avm-res-web-serverfarm/azurerm` 2.0.8.

## Notes

- Defaults to a Linux `P1v3` plan with one instance. The upstream module defaults to three instances with zone balancing, which this wrapper turns off to keep the default deployment cheap.
- Zone balancing (`zone_balancing_enabled = true`) needs a Premium v2/v3 SKU and at least three instances.
- Windows and Linux apps cannot share a plan. Set `os_type` accordingly.

## Usage

```hcl
module "plan" {
  source = "../../res/web/app-service-plan"

  name              = "asp-example"
  location          = "westeurope"
  resource_group_id = azurerm_resource_group.this.id
  sku_name          = "P1v3"
}
```

## Tests

- [tests/defaults](tests/defaults/main.tf): Linux P1v3
