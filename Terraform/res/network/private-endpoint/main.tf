locals {
  resource_group_name = element(split("/", var.resource_group_id), 4)
}

module "private_endpoint" {
  source  = "Azure/avm-res-network-privateendpoint/azurerm"
  version = "0.2.0"

  name                            = var.name
  location                        = var.location
  resource_group_name             = local.resource_group_name
  tags                            = var.tags
  subnet_resource_id              = var.subnet_resource_id
  network_interface_name          = "nic-${var.name}"
  private_connection_resource_id  = var.private_link_service_resource_id
  private_service_connection_name = var.name
  subresource_names               = var.group_ids
  private_dns_zone_resource_ids   = var.private_dns_zone_resource_ids
}
