locals {
  resource_group_name = element(split("/", var.resource_group_id), 4)
  frontend_name       = "frontend"

  backend_address_pools = {
    for pool_name in var.backend_pool_names : pool_name => {
      name = pool_name
    }
  }

  lb_probes = {
    for probe_name, probe in var.probes : probe_name => {
      name                            = probe_name
      protocol                        = probe.protocol
      port                            = probe.port
      request_path                    = probe.request_path
      interval_in_seconds             = probe.interval_in_seconds
      number_of_probes_before_removal = probe.number_of_probes
    }
  }

  lb_rules = {
    for rule_name, rule in var.load_balancing_rules : rule_name => {
      name                              = rule_name
      protocol                          = rule.protocol
      frontend_port                     = rule.frontend_port
      backend_port                      = rule.backend_port
      frontend_ip_configuration_name    = local.frontend_name
      backend_address_pool_object_names = [rule.backend_pool_name]
      probe_object_name                 = rule.probe_name
    }
  }

  diagnostic_settings = var.diagnostics == null ? {} : {
    default = {
      workspace_resource_id = var.diagnostics.workspace_resource_id
    }
  }
}

module "load_balancer" {
  source  = "Azure/avm-res-network-loadbalancer/azurerm"
  version = "0.5.0"

  name                = var.name
  location            = var.location
  resource_group_name = local.resource_group_name
  tags                = var.tags
  sku                 = var.sku_name

  frontend_ip_configurations = {
    (local.frontend_name) = {
      name                                   = local.frontend_name
      frontend_private_ip_subnet_resource_id = var.subnet_resource_id
      frontend_private_ip_address            = var.frontend_private_ip_address != "" ? var.frontend_private_ip_address : null
      frontend_private_ip_address_allocation = var.frontend_private_ip_address != "" ? "Static" : "Dynamic"
    }
  }
  backend_address_pools = local.backend_address_pools
  lb_probes             = local.lb_probes
  lb_rules              = local.lb_rules

  diagnostic_settings = local.diagnostic_settings
  role_assignments    = var.role_assignments
}
