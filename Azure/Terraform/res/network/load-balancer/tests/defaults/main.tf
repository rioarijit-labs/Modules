# Standard internal load balancer with a health probe and one balancing rule.
# Placeholder IDs: the test validates the module contract, it does not resolve these resources.
provider "azurerm" {
  features {}
}

module "test" {
  source = "../../"

  name               = "lb-defaults"
  location           = "westeurope"
  resource_group_id  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example"
  subnet_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example/providers/Microsoft.Network/virtualNetworks/vnet-example/subnets/snet-workload"
  backend_pool_names = ["web-instances"]

  probes = {
    http_health = {
      protocol     = "Http"
      port         = 80
      request_path = "/healthz"
    }
  }

  load_balancing_rules = {
    http = {
      protocol          = "Tcp"
      frontend_port     = 80
      backend_port      = 80
      backend_pool_name = "web-instances"
      probe_name        = "http_health"
    }
  }
}
