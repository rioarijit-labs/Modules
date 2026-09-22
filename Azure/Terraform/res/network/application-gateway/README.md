# Application Gateway

Layer 7 load balancer and reverse proxy. Wraps `Azure/avm-res-network-applicationgateway/azurerm` 0.5.3.

## Scope: HTTP only in this preview

This module wires HTTP listeners only, matching the Bicep flavor. HTTPS/TLS termination needs certificate management, not covered here yet.

## Sub-resource IDs are computed, not looked up

Application Gateway's sub-resources (frontend ports, probes, listeners, backend settings) reference each other by full Azure resource ID *within the same resource*, and Terraform can't resolve a resource's own not-yet-created sub-resource IDs through the normal `module.x.output` mechanism without a dependency cycle. Since Azure resource IDs are fully deterministic from the subscription, resource group, resource type and name, this module computes them as plain strings from `resource_group_id` and `var.name` (see `local.gateway_resource_id` in `main.tf`) instead.

## Defaults

- `WAF_v2` SKU, so every deployment gets a WAF unless you deliberately choose `Standard_v2`
- Autoscale from 0 to 10 instances

## How routing is built

You declare four flat, keyed maps — `backends`, `backend_settings`, `listeners`, `routing_rules` — and the module wires the cross-references (frontend port, probe, backend pool, backend setting) for you. A routing rule connects one `listener_name` to one `backend_name` using one `backend_setting_name`; all three must exist as keys in their respective maps.

## Usage

```hcl
module "gateway" {
  source = "../../res/network/application-gateway"

  name                          = "agw-public-001"
  location                      = "westeurope"
  resource_group_id             = azurerm_resource_group.this.id
  subnet_resource_id            = module.network.subnet_resource_ids["app_gateway"]
  public_ip_resource_id         = azurerm_public_ip.gateway.id
  firewall_policy_resource_id   = module.waf_policy.resource_id

  backends = {
    app = { fqdns = [module.app.default_hostname] }
  }

  backend_settings = {
    app_https = { port = 443, protocol = "Https", probe_path = "/healthz", pick_host_name_from_backend_address = true }
  }

  listeners = {
    public = { port = 80, host_name = "www.example.com" }
  }

  routing_rules = {
    route_app = { priority = 100, listener_name = "public", backend_name = "app", backend_setting_name = "app_https" }
  }
}
```

## Tests

- [tests/defaults](tests/defaults/main.tf): public gateway routing to an App Service backend by FQDN
