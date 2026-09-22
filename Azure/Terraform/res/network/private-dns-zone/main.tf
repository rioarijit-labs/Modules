locals {
  virtual_network_links = {
    for link_name, virtual_network_id in var.virtual_network_resource_ids : link_name => {
      name                 = "link-${link_name}"
      virtual_network_id   = virtual_network_id
      registration_enabled = var.registration_enabled
      tags                 = var.tags
    }
  }
}

module "private_dns_zone" {
  source  = "Azure/avm-res-network-privatednszone/azurerm"
  version = "0.5.0"

  domain_name           = var.name
  parent_id             = var.resource_group_id
  tags                  = var.tags
  virtual_network_links = local.virtual_network_links
}
