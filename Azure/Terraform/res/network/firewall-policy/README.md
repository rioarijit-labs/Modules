# Azure Firewall policy

Rule collections for Azure Firewall. Wraps `Azure/avm-res-network-firewallpolicy/azurerm` 0.3.4.

## An upstream gap this module fills in

The AVM module wraps only the policy resource itself — it has no way to create rule collection groups (the AzureRM provider models those as a separate resource, `azurerm_firewall_policy_rule_collection_group`). Since a policy with no rules blocks everything, this module creates that resource directly, `for_each` over `rule_collection_groups`.

## How rules are organized

Each entry in `rule_collection_groups` becomes a group containing up to two Allow collections (one for `network_rules`, one for `application_rules`) — everything you list is allowed, and Azure Firewall denies by default beneath it.

- **Network rules** match on IP, port and protocol (L3/L4).
- **Application rules** match on FQDN for HTTP/HTTPS traffic — the more common and more precise choice for typical outbound web/API traffic.

## Usage

This module produces a policy with no firewall to attach it to. Pass its `resource_id` to the [azure-firewall](../azure-firewall) module's `firewall_policy_resource_id`.

```hcl
module "firewall_policy" {
  source = "../../res/network/firewall-policy"

  name              = "fwpolicy-hub-001"
  location          = "westeurope"
  resource_group_id = azurerm_resource_group.this.id

  rule_collection_groups = {
    spoke_egress = {
      priority = 200
      application_rules = {
        allow_updates = {
          priority          = 201
          source_addresses  = ["10.0.0.0/16"]
          destination_fqdns = ["*.microsoft.com"]
          protocol_type     = "Https"
          protocol_port     = 443
        }
      }
    }
  }
}
```

## Tests

- [tests/defaults](tests/defaults/main.tf): one group with a network rule and an application rule
