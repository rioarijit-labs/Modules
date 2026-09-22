locals {
  resource_group_name = element(split("/", var.resource_group_id), 4)

  # The gateway's own resource ID is deterministic from its name, so sub-resource IDs (frontend
  # port, probe, backend pool, etc.) can be computed before the resource exists, exactly as Azure
  # itself will name them. This avoids a dependency cycle within the same resource.
  gateway_resource_id = "${var.resource_group_id}/providers/Microsoft.Network/applicationGateways/${var.name}"

  frontend_ip_config_name = "frontend"
  frontend_ports          = toset([for listener in var.listeners : listener.port])

  gateway_ip_configurations = [
    {
      name = "gateway"
      properties = {
        subnet = { id = var.subnet_resource_id }
      }
    }
  ]

  frontend_ip_configurations = [
    {
      name = local.frontend_ip_config_name
      properties = {
        public_ip_address            = var.public_ip_resource_id != "" ? { id = var.public_ip_resource_id } : null
        private_ip_address           = var.private_frontend_ip_address != "" ? var.private_frontend_ip_address : null
        private_ip_allocation_method = var.private_frontend_ip_address != "" ? "Static" : null
        subnet                       = var.private_frontend_ip_address != "" ? { id = var.subnet_resource_id } : null
      }
    }
  ]

  frontend_port_resources = {
    for port in local.frontend_ports : tostring(port) => {
      name       = "port-${port}"
      properties = { port = port }
    }
  }

  backend_address_pools = [
    for backend_name, backend in var.backends : {
      name = backend_name
      properties = {
        backend_addresses = concat(
          [for ip in backend.ip_addresses : { ip_address = ip }],
          [for fqdn in backend.fqdns : { fqdn = fqdn }]
        )
      }
    }
  ]

  backend_http_settings_collection = [
    for setting_name, setting in var.backend_settings : {
      name = setting_name
      properties = {
        port                                = setting.port
        protocol                            = setting.protocol
        pick_host_name_from_backend_address = setting.pick_host_name_from_backend_address
        probe_enabled                       = true
        probe                               = { id = "${local.gateway_resource_id}/probes/${setting_name}-probe" }
      }
    }
  ]

  probes = [
    for setting_name, setting in var.backend_settings : {
      name = "${setting_name}-probe"
      properties = {
        protocol                                  = setting.protocol
        path                                      = setting.probe_path
        interval                                  = 30
        timeout                                   = 30
        unhealthy_threshold                       = 3
        pick_host_name_from_backend_http_settings = true
      }
    }
  ]

  http_listeners = [
    for listener_name, listener in var.listeners : {
      name = listener_name
      properties = {
        frontend_ip_configuration = { id = "${local.gateway_resource_id}/frontendIPConfigurations/${local.frontend_ip_config_name}" }
        frontend_port             = { id = "${local.gateway_resource_id}/frontendPorts/port-${listener.port}" }
        protocol                  = "Http"
        host_name                 = listener.host_name
      }
    }
  ]

  request_routing_rules = [
    for rule_name, rule in var.routing_rules : {
      name = rule_name
      properties = {
        rule_type             = "Basic"
        priority              = rule.priority
        http_listener         = { id = "${local.gateway_resource_id}/httpListeners/${rule.listener_name}" }
        backend_address_pool  = { id = "${local.gateway_resource_id}/backendAddressPools/${rule.backend_name}" }
        backend_http_settings = { id = "${local.gateway_resource_id}/backendHttpSettingsCollection/${rule.backend_setting_name}" }
      }
    }
  ]

  diagnostic_settings = var.diagnostics == null ? {} : {
    default = {
      workspace_resource_id = var.diagnostics.workspace_resource_id
    }
  }
}

module "application_gateway" {
  source  = "Azure/avm-res-network-applicationgateway/azurerm"
  version = "0.5.3"

  name      = var.name
  location  = var.location
  parent_id = var.resource_group_id
  tags      = var.tags

  sku = {
    name = var.sku_name
    tier = var.sku_name
  }
  autoscale_configuration = {
    min_capacity = var.autoscale_min_capacity
    max_capacity = var.autoscale_max_capacity
  }
  firewall_policy = var.sku_name == "WAF_v2" && var.firewall_policy_resource_id != "" ? {
    id = var.firewall_policy_resource_id
  } : null

  gateway_ip_configurations        = local.gateway_ip_configurations
  frontend_ip_configurations       = local.frontend_ip_configurations
  frontend_ports                   = values(local.frontend_port_resources)
  backend_address_pools            = local.backend_address_pools
  backend_http_settings_collection = local.backend_http_settings_collection
  probes                           = local.probes
  http_listeners                   = local.http_listeners
  request_routing_rules            = local.request_routing_rules

  diagnostic_settings = local.diagnostic_settings
  role_assignments    = var.role_assignments
}
