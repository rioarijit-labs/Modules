# Container Apps environment

Environment that hosts container apps. Wraps `Azure/avm-res-app-managedenvironment/azurerm` 0.5.0.

## Defaults

- Workload profiles environment with the pay-per-use `Consumption` profile
- Public network access **disabled**
- With a VNet, an **internal** load balancer: apps get private IPs
- Logs go to Log Analytics through diagnostic settings (`azure-monitor` destination), so no workspace shared key is passed around

## Networking

- The infrastructure subnet must be **delegated to `Microsoft.App/environments`**, be at least `/27`, and be dedicated to the environment.
- For an internal environment, create a private DNS zone named after the environment's `default_domain` output with a wildcard `*` A record pointing at the `static_ip_address` output, and link it to the networks that call the apps.
- Without a VNet the environment is external and gets a public endpoint, but `public_network_access_enabled` defaults to `false`: set it to `true` for a simple public lab.
- A private endpoint for the environment is not exposed: the upstream module does not offer it. Use the [private-endpoint](../../network/private-endpoint) module if you need one.

## Usage

```hcl
module "environment" {
  source = "../../res/app/managed-environment"

  name                              = "cae-example-001"
  location                          = "westeurope"
  resource_group_id                 = azurerm_resource_group.this.id
  infrastructure_subnet_resource_id = module.network.subnet_resource_ids["container_apps"]
  diagnostics                       = { workspace_resource_id = module.logs.resource_id }
}
```

The `virtual-network` subnet for it needs `delegation = "Microsoft.App/environments"`.

## Tests

- [tests/defaults](tests/defaults/main.tf): internal environment in a subnet with Log Analytics logging
