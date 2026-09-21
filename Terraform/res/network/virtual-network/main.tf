locals {
  subnets = {
    for key, subnet in var.subnets : key => {
      name                   = subnet.name
      address_prefixes       = [subnet.address_prefix]
      network_security_group = subnet.network_security_group_resource_id == null ? null : { id = subnet.network_security_group_resource_id }
      route_table            = subnet.route_table_resource_id == null ? null : { id = subnet.route_table_resource_id }
      service_endpoints      = subnet.service_endpoints
      delegations = subnet.delegation == null ? [] : [{
        name               = "delegation"
        service_delegation = { name = subnet.delegation }
      }]
      private_endpoint_network_policies = subnet.private_endpoint_network_policies
      default_outbound_access_enabled   = subnet.default_outbound_access_enabled
    }
  }

  peerings = {
    for key, peering in var.peerings : key => {
      name                               = key
      remote_virtual_network_resource_id = peering.remote_virtual_network_resource_id
      allow_forwarded_traffic            = peering.allow_forwarded_traffic
      allow_gateway_transit              = peering.allow_gateway_transit
      allow_virtual_network_access       = peering.allow_virtual_network_access
      use_remote_gateways                = peering.use_remote_gateways
      create_reverse_peering             = peering.create_reverse_peering
    }
  }

  diagnostic_settings = var.diagnostics == null ? {} : {
    default = {
      workspace_resource_id = var.diagnostics.workspace_resource_id
    }
  }
}

module "virtual_network" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm"
  version = "0.22.2"

  name          = var.name
  location      = var.location
  parent_id     = var.resource_group_id
  tags          = var.tags
  address_space = toset(var.address_space)
  subnets       = local.subnets
  dns_servers   = length(var.dns_servers) == 0 ? null : { dns_servers = var.dns_servers }
  peerings      = local.peerings

  diagnostic_settings = local.diagnostic_settings
}
