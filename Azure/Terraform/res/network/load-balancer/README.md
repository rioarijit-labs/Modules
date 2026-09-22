# Load balancer

Internal load balancer for VM or VMSS instances. Wraps `Azure/avm-res-network-loadbalancer/azurerm` 0.5.0.

## Scope

This module always creates an **internal** load balancer, with its frontend IP in a subnet you provide. There is no public-facing option here on purpose: internet-facing traffic in this repo goes through Application Gateway or Front Door, which add a WAF; a bare public load balancer has none.

## How the pieces connect

- `backend_pool_names` creates empty backend pools, keyed by the pool name. Add instances to a pool from the VM or VMSS side after this module deploys — this module doesn't attach instances itself.
- `probes` and `load_balancing_rules` are maps keyed by an arbitrary name; a rule references a probe and a backend pool by the keys you gave them elsewhere.

## Usage

```hcl
module "load_balancer" {
  source = "../../res/network/load-balancer"

  name                = "lb-web-001"
  location            = "westeurope"
  resource_group_id   = azurerm_resource_group.this.id
  subnet_resource_id  = module.network.subnet_resource_ids["workload"]
  backend_pool_names  = ["web-instances"]

  probes = {
    http_health = { protocol = "Http", port = 80, request_path = "/healthz" }
  }

  load_balancing_rules = {
    http = { protocol = "Tcp", frontend_port = 80, backend_port = 80, backend_pool_name = "web-instances", probe_name = "http_health" }
  }
}
```

## Tests

- [tests/defaults](tests/defaults/main.tf): one backend pool, one health probe, one rule
