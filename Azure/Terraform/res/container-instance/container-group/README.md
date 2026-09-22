# Container instance

A group of containers on Azure Container Instances, no orchestrator. Wraps `Azure/avm-res-containerinstance-containergroup/azurerm` 0.2.0.

## Defaults

- **No public IP.** The group gets a private IP inside the subnet you pass; there is no separate private endpoint concept for the group's own placement, it lives directly in the VNet. (This module's `private_endpoints` variable, if you look at the underlying AVM module, is for a different purpose than the placement itself and is not wired here.)
- `restart_policy` defaults to `Always` (a long-running process); set it to `Never` for a one-off job or `OnFailure` for a retryable task.

## More capable than the Bicep flavor, here

Unlike this repo's Bicep container-instance module, the underlying Terraform AVM module (0.2.0) *does* expose `role_assignments`, so this wrapper has one. That is a real difference between the two AVM ecosystems for the same resource, not a design choice.

## Multiple containers

Containers in the same group share a network namespace and can reach each other over `localhost`. This is the sidecar pattern (e.g. an app container plus a log-shipping sidecar), not a way to run unrelated workloads together — unrelated jobs should be separate container groups.

## Usage

```hcl
module "job" {
  source = "../../res/container-instance/container-group"

  name                = "aci-nightly-import"
  location            = "westeurope"
  resource_group_id   = azurerm_resource_group.this.id
  subnet_resource_id  = module.network.subnet_resource_ids["workload"]
  restart_policy       = "Never"

  containers = {
    import = {
      image  = "${module.registry.login_server}/import-job:1.0.0"
      cpu    = 1
      memory = 2
      environment_variables = {
        TARGET_DATE = "today"
      }
    }
  }
}
```

## Tests

- [tests/defaults](tests/defaults/main.tf): a one-off job with plain and secret environment variables
