metadata name = 'WAF policy - defaults'
metadata description = 'Prevention mode with the OWASP 3.2 rule set and a custom rule blocking a source range.'

module test '../../main.bicep' = {
  name: 'test-waf-policy-defaults'
  params: {
    name: 'waf-defaults'
    customRules: [
      {
        name: 'block-test-range'
        priority: 1
        action: 'Block'
        matchConditions: [
          {
            matchVariables: [
              { variableName: 'RemoteAddr' }
            ]
            operator: 'IPMatch'
            matchValues: ['198.51.100.0/24']
          }
        ]
      }
    ]
  }
}
