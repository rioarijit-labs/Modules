# Web Application Firewall policy

WAF policy with the OWASP managed rule set. Wraps `br/public:avm/res/network/application-gateway-web-application-firewall-policy:0.3.0`.

## Defaults

- `Prevention` mode: matching requests are blocked, not just logged. Switch to `Detection` first when validating a new rule set against real traffic, then move to `Prevention`.
- OWASP Core Rule Set 3.2

## Usage

This module produces a policy with no gateway to attach it to. Pass its `resourceId` to the [application-gateway](../application-gateway) module's `firewallPolicyResourceId`.

```bicep
module wafPolicy '../../res/network/waf-policy/main.bicep' = {
  name: 'waf-policy'
  params: {
    name: 'waf-public-001'
    customRules: [
      {
        name: 'block-known-bad-range'
        priority: 1
        action: 'Block'
        matchConditions: [
          {
            matchVariables: [{ variableName: 'RemoteAddr' }]
            operator: 'IPMatch'
            matchValues: ['198.51.100.0/24']
          }
        ]
      }
    ]
  }
}
```

## Tests

- [tests/defaults](tests/defaults/main.test.bicep): OWASP 3.2 plus one custom IP-block rule
