# Public WAF_v2 gateway routing one host name to an App Service backend by FQDN.
# Placeholder IDs: the test validates the module contract, it does not resolve these resources.
provider "azurerm" {
  features {}
}

module "test" {
  source = "../../"

  name               = "agw-defaults"
  location           = "westeurope"
  resource_group_id  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example"
  subnet_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example/providers/Microsoft.Network/virtualNetworks/vnet-example/subnets/snet-appgw"

  public_ip_resource_id       = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example/providers/Microsoft.Network/publicIPAddresses/pip-agw-example"
  firewall_policy_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example/providers/Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies/waf-example"

  backends = {
    app_backend = {
      fqdns = ["app-example-001.azurewebsites.net"]
    }
  }

  backend_settings = {
    app_https = {
      port                                = 443
      protocol                            = "Https"
      probe_path                          = "/healthz"
      pick_host_name_from_backend_address = true
    }
  }

  listeners = {
    public_http = {
      port      = 80
      host_name = "www.example.com"
    }
  }

  routing_rules = {
    route_to_app = {
      priority             = 100
      listener_name        = "public_http"
      backend_name         = "app_backend"
      backend_setting_name = "app_https"
    }
  }
}
