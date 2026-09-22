# Azure Firewall policy

Rule collections for Azure Firewall. Wraps `br/public:avm/res/network/firewall-policy:0.3.6`.

## How rules are organized

Azure Firewall evaluates traffic through: rule collection **groups** (ordered by `priority`) → rule **collections** within a group → individual **rules** within a collection. This module simplifies that to one level: each entry in `ruleCollectionGroups` becomes a group containing up to two Allow collections (one for `networkRules`, one for `applicationRules`) — everything you list is allowed, and Azure Firewall denies by default beneath it.

- **Network rules** match on IP, port and protocol (L3/L4) — use them for non-HTTP(S) traffic, or when you need to allow by IP rather than domain.
- **Application rules** match on FQDN for HTTP/HTTPS traffic the firewall can inspect at Layer 7 — the more common and more precise choice for typical outbound web/API traffic.

## Usage

This module produces a policy with no firewall to attach it to. Pass its `resourceId` to the [azure-firewall](../azure-firewall) module's `firewallPolicyResourceId`.

```bicep
module firewallPolicy '../../res/network/firewall-policy/main.bicep' = {
  name: 'firewall-policy'
  params: {
    name: 'fwpolicy-hub-001'
    ruleCollectionGroups: [
      {
        name: 'spoke-egress'
        priority: 200
        applicationRules: [
          {
            name: 'allow-updates'
            sourceAddresses: ['10.0.0.0/16']
            targetFqdns: ['*.microsoft.com']
            protocols: [{ protocolType: 'Https', port: 443 }]
          }
        ]
      }
    ]
  }
}
```

## Tests

- [tests/defaults](tests/defaults/main.test.bicep): one group with a network rule and an application rule
