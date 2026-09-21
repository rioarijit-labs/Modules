locals {
  resource_group_name = element(split("/", var.resource_group_id), 4)
  is_premium          = var.sku_name == "Premium"

  queues = {
    for queue_name, queue in var.queues : queue_name => merge(queue, { name = queue_name })
  }

  topics = {
    for topic_name, topic in var.topics : topic_name => {
      name                         = topic_name
      default_message_ttl          = topic.default_message_ttl
      requires_duplicate_detection = topic.requires_duplicate_detection
      subscriptions = {
        for subscription_name, subscription in topic.subscriptions : subscription_name => merge(subscription, { name = subscription_name })
      }
    }
  }

  private_endpoints = var.private_endpoint == null ? {} : {
    namespace = {
      subnet_resource_id            = var.private_endpoint.subnet_resource_id
      private_dns_zone_resource_ids = toset(var.private_endpoint.private_dns_zone_resource_ids)
      tags                          = var.tags
    }
  }

  diagnostic_settings = var.diagnostics == null ? {} : {
    default = {
      workspace_resource_id = var.diagnostics.workspace_resource_id
    }
  }
}

module "namespace" {
  source  = "Azure/avm-res-servicebus-namespace/azurerm"
  version = "0.4.0"

  name                = var.name
  location            = var.location
  resource_group_name = local.resource_group_name
  tags                = var.tags
  sku                 = var.sku_name
  capacity            = local.is_premium ? var.premium_capacity : null

  # Secure defaults: Entra ID only, TLS 1.2, private access
  local_auth_enabled            = false
  minimum_tls_version           = "1.2"
  public_network_access_enabled = var.public_network_access_enabled

  queues              = local.queues
  topics              = local.topics
  private_endpoints   = local.private_endpoints
  diagnostic_settings = local.diagnostic_settings
  managed_identities = {
    system_assigned = var.enable_system_assigned_identity
  }
  role_assignments = var.role_assignments
}
