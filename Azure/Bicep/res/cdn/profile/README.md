# Front Door

Azure Front Door profile. Wraps `br/public:avm/res/cdn/profile:0.20.0`.

## Scope: no WAF in this preview

Front Door's WAF policy is a **different resource type** (`Microsoft.Network/FrontDoorWebApplicationFirewallPolicies`) from the one this repo's [waf-policy](../../network/waf-policy) module wraps (which is Application Gateway's WAF policy type — same concept, different ARM resource). This module does not attach a WAF policy yet. Add `securityPolicies` (wiring a Front Door WAF policy resource ID) when you need one; it isn't built here to avoid a second, easily-confused "WAF policy" module in this pass.

## Defaults

- `Standard_AzureFrontDoor` SKU (Premium adds WAF-capable security features via `securityPolicies`, private link to origins and bot protection)
- One origin group with health probing, one route matching everything (`/*`), HTTPS redirect on
- Managed (free) TLS certificates for any custom domain you add

## One origin group per deployment

This module creates a single origin group with one route. For multiple backends routed by path (e.g. `/api/*` to one origin, `/*` to another), deploy the module twice with different `endpointName`/`routePatterns`, or extend it to accept multiple origin groups if you need that in one profile.

## DNS for a custom domain

Point a CNAME (or an ALIAS/ANAME record at the zone apex) at this module's `endpointHostName` output, then add the domain to `customDomainNames`. Front Door validates domain ownership and issues a managed certificate automatically; there's a short delay (usually a few minutes) after adding the domain before the certificate is ready and HTTPS works.

## Usage

```bicep
module frontDoor '../../res/cdn/profile/main.bicep' = {
  name: 'front-door'
  params: {
    name: 'afd-example-001'
    origins: [
      { name: 'app', hostName: app.outputs.defaultHostname }
    ]
    healthProbePath: '/healthz'
    customDomainNames: ['www.example.com']
  }
}
```

## Tests

- [tests/defaults](tests/defaults/main.test.bicep): one origin, a health probe and a custom domain
