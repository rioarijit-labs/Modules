metadata name = 'Application Gateway - defaults'
metadata description = 'Public WAF_v2 gateway routing one host name to an App Service backend by FQDN.'

// Placeholder IDs: the test validates the module contract, it does not resolve these resources.
module test '../../main.bicep' = {
  name: 'test-application-gateway-defaults'
  params: {
    name: 'agw-defaults'
    subnetResourceId: '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example/providers/Microsoft.Network/virtualNetworks/vnet-example/subnets/snet-appgw'
    publicIpResourceId: '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example/providers/Microsoft.Network/publicIPAddresses/pip-agw-example'
    firewallPolicyResourceId: '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example/providers/Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies/waf-example'
    backends: [
      {
        name: 'app-backend'
        fqdns: ['app-example-001.azurewebsites.net']
      }
    ]
    backendSettings: [
      {
        name: 'app-https'
        port: 443
        protocol: 'Https'
        probePath: '/healthz'
        pickHostNameFromBackendAddress: true
      }
    ]
    listeners: [
      {
        name: 'public-http'
        port: 80
        hostName: 'www.example.com'
      }
    ]
    routingRules: [
      {
        name: 'route-to-app'
        priority: 100
        listenerName: 'public-http'
        backendName: 'app-backend'
        backendSettingName: 'app-https'
      }
    ]
  }
}
