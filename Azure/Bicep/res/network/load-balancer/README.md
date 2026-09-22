# Load balancer

Internal load balancer for VM or VMSS instances. Wraps `br/public:avm/res/network/load-balancer:0.8.0`.

## Scope

This module always creates an **internal** load balancer, with its frontend IP in a subnet you provide. There is no public-facing option here on purpose: internet-facing traffic in this repo goes through Application Gateway or Front Door, which add a WAF; a bare public load balancer has none.

## How the pieces connect

- `backendPoolNames` creates empty backend pools. Add instances to a pool from the VM or VMSS side (a VM's NIC IP configuration, or a VMSS's backend pool reference) after this module deploys — this module doesn't attach instances itself.
- `probes` define health checks; `loadBalancingRules` reference a probe and a backend pool by the names you gave them.

## Usage

```bicep
module loadBalancer '../../res/network/load-balancer/main.bicep' = {
  name: 'lb'
  params: {
    name: 'lb-web-001'
    subnetResourceId: vnet.outputs.subnetResourceIds[0]
    backendPoolNames: ['web-instances']
    probes: [
      { name: 'http-health', protocol: 'Http', port: 80, requestPath: '/healthz' }
    ]
    loadBalancingRules: [
      { name: 'http', protocol: 'Tcp', frontendPort: 80, backendPort: 80, backendPoolName: 'web-instances', probeName: 'http-health' }
    ]
  }
}
```

## Tests

- [tests/defaults](tests/defaults/main.test.bicep): one backend pool, one health probe, one rule
