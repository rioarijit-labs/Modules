# Application Gateway

Layer 7 load balancer and reverse proxy. Wraps `br/public:avm/res/network/application-gateway:0.10.0`.

## Scope: HTTP only in this preview

This module wires HTTP listeners only. HTTPS/TLS termination needs certificate management (a Key Vault-referenced certificate plus a user-assigned identity with access to it), which this module does not cover yet. Two ways to still get HTTPS to users today:

- Put [Front Door](../../cdn/profile) in front of this gateway and terminate TLS there, with plain HTTP from Front Door to the gateway (Front Door's own IP ranges, not the public internet, reach the gateway).
- Add HTTPS support to this module yourself when you need it — `sslCertificates` and a listener with `protocol: 'Https'` referencing a certificate are the two additions.

## Defaults

- `WAF_v2` SKU, so every deployment gets a WAF unless you deliberately choose `Standard_v2`
- Autoscale from 0 to 10 instances

## How routing is built

You declare four flat, named lists — `backends`, `backendSettings`, `listeners`, `routingRules` — and the module wires the cross-references (frontend port, probe, backend pool, backend setting) for you. A `routingRule` connects one `listenerName` to one `backendName` using one `backendSettingName`; all three must exist in their respective lists.

## Usage

```bicep
module gateway '../../res/network/application-gateway/main.bicep' = {
  name: 'gateway'
  params: {
    name: 'agw-public-001'
    subnetResourceId: vnet.outputs.subnetResourceIds['app_gateway']
    publicIpResourceId: publicIp.outputs.resourceId
    firewallPolicyResourceId: wafPolicy.outputs.resourceId
    backends: [
      { name: 'app', fqdns: [app.outputs.defaultHostname] }
    ]
    backendSettings: [
      { name: 'app-https', port: 443, protocol: 'Https', probePath: '/healthz', pickHostNameFromBackendAddress: true }
    ]
    listeners: [
      { name: 'public', port: 80, hostName: 'www.example.com' }
    ]
    routingRules: [
      { name: 'route-app', priority: 100, listenerName: 'public', backendName: 'app', backendSettingName: 'app-https' }
    ]
  }
}
```

## Tests

- [tests/defaults](tests/defaults/main.test.bicep): public gateway routing to an App Service backend by FQDN
