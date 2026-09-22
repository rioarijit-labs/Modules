locals {
  resource_group_name = element(split("/", var.resource_group_id), 4)
}

module "firewall_policy" {
  source  = "Azure/avm-res-network-firewallpolicy/azurerm"
  version = "0.3.4"

  name                = var.name
  location            = var.location
  resource_group_name = local.resource_group_name
  tags                = var.tags

  firewall_policy_sku                      = var.sku
  firewall_policy_threat_intelligence_mode = var.threat_intelligence_mode
  role_assignments                         = var.role_assignments
}

# The upstream AVM module does not create rule collection groups, only the policy resource itself.
# A policy with no rules blocks everything, so this module creates them directly.
resource "azurerm_firewall_policy_rule_collection_group" "this" {
  for_each = var.rule_collection_groups

  name               = each.key
  firewall_policy_id = module.firewall_policy.resource_id
  priority           = each.value.priority

  dynamic "network_rule_collection" {
    for_each = length(each.value.network_rules) > 0 ? [1] : []
    content {
      name     = "${each.key}-network"
      priority = each.value.priority
      action   = "Allow"

      dynamic "rule" {
        for_each = each.value.network_rules
        content {
          name                  = rule.key
          protocols             = rule.value.protocols
          source_addresses      = rule.value.source_addresses
          destination_addresses = rule.value.destination_addresses
          destination_ports     = rule.value.destination_ports
        }
      }
    }
  }

  dynamic "application_rule_collection" {
    for_each = length(each.value.application_rules) > 0 ? [1] : []
    content {
      name     = "${each.key}-application"
      priority = each.value.priority + 1
      action   = "Allow"

      dynamic "rule" {
        for_each = each.value.application_rules
        content {
          name              = rule.key
          source_addresses  = rule.value.source_addresses
          destination_fqdns = rule.value.destination_fqdns

          protocols {
            type = rule.value.protocol_type
            port = rule.value.protocol_port
          }
        }
      }
    }
  }
}
