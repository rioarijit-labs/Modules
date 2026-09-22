# Front Door

Azure Front Door profile: a global entry point with CDN caching, health-probed origin failover and managed TLS. Wraps `Azure/avm-res-cdn-profile/azurerm` 0.1.9.

## Defaults

- **Standard_AzureFrontDoor** SKU — CDN and global load balancing without Premium's WAF-capable security layer, private link to origins or bot protection
- HTTPS enforced end to end: `https_redirect_enabled = true` on the route, and TLS to origins by default (`origin_protocol = "Https"`)
- Managed TLS certificates for custom domains (`certificate_type = "ManagedCertificate"`) — no certificate to provision or rotate yourself

## Design: one origin group, one route

This module creates a single origin group, a single endpoint and a single route, with as many origins in that group as you give it in `origins` — Front Door load-balances and fails over across them by `priority`/`weight`. This covers the common case (one app, multiple regional origins) without the full generality of the underlying AVM module's independently keyed maps. For multiple distinct routes or origin groups (e.g. path-based routing to different backends), compose the AVM module directly.

## WAF

This module does not attach a WAF policy. Front Door's WAF policy is a distinct resource type (`azurerm_cdn_frontdoor_firewall_policy`) from this repo's [network/waf-policy](../../network/waf-policy) module, which targets Application Gateway. Add a Front Door WAF policy natively, or via a future dedicated module, and associate it with the security policy on the AVM module directly if needed.

## Custom domains

`custom_domain_names` registers the binding and requests a managed certificate for each domain. DNS (a CNAME to the endpoint hostname, or an ALIAS/ANAME record at a zone apex) must already point at Front Door before validation succeeds — this module does not create DNS records.

## Usage

```hcl
module "front_door" {
  source = "../../res/cdn/profile"

  name              = "afd-storefront-001"
  resource_group_id = azurerm_resource_group.this.id

  origins = {
    primary   = { host_name = "app-primary.azurewebsites.net" }
    secondary = { host_name = "app-secondary.azurewebsites.net", priority = 2 }
  }

  custom_domain_names = ["www.contoso.com"]
}
```

## Tests

- [tests/defaults](tests/defaults/main.tf): single origin, default route
