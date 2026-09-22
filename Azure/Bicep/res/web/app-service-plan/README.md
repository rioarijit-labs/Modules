# App Service plan

Compute plan for App Service web apps and function apps. Wraps `br/public:avm/res/web/serverfarm:0.7.0`.

## Notes

- Defaults to a Linux `P1v3` plan with one instance.
- Zone redundancy (`zoneRedundant: true`) needs a Premium v2/v3 SKU and at least three instances.
- Windows and Linux apps cannot share a plan. Set `osType` accordingly.

## Usage

```bicep
module plan '../../res/web/app-service-plan/main.bicep' = {
  name: 'plan'
  params: {
    name: 'asp-example'
    skuName: 'P1v3'
  }
}
```

## Tests

- [tests/defaults](tests/defaults/main.test.bicep): Linux P1v3
