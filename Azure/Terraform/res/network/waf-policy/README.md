# Web Application Firewall policy

WAF policy with the OWASP managed rule set. Wraps `Azure/avm-res-network-applicationgatewaywebapplicationfirewallpolicy/azurerm` 0.2.0.

## Defaults

- `Prevention` mode: matching requests are blocked, not just logged. Switch to `Detection` first when validating a new rule set against real traffic, then move to `Prevention`.
- OWASP Core Rule Set 3.2

## Usage

This module produces a policy with no gateway to attach it to. Pass its `resource_id` to the [application-gateway](../application-gateway) module's `firewall_policy_resource_id`.

```hcl
module "waf_policy" {
  source = "../../res/network/waf-policy"

  name              = "waf-public-001"
  location          = "westeurope"
  resource_group_id = azurerm_resource_group.this.id

  custom_rules = {
    block_known_bad_range = {
      priority = 1
      action   = "Block"
      match_conditions = [
        {
          match_variables = [{ variable_name = "RemoteAddr" }]
          operator        = "IPMatch"
          match_values    = ["198.51.100.0/24"]
        }
      ]
    }
  }
}
```

## Tests

- [tests/defaults](tests/defaults/main.tf): OWASP 3.2 plus one custom IP-block rule
