locals {
  resource_group_name = element(split("/", var.resource_group_id), 4)

  custom_rules = {
    for rule_name, rule in var.custom_rules : rule_name => {
      name      = rule_name
      priority  = rule.priority
      action    = rule.action
      rule_type = "MatchRule"
      match_conditions = {
        for index, condition in rule.match_conditions : tostring(index) => condition
      }
    }
  }
}

module "waf_policy" {
  source  = "Azure/avm-res-network-applicationgatewaywebapplicationfirewallpolicy/azurerm"
  version = "0.2.0"

  name                = var.name
  location            = var.location
  resource_group_name = local.resource_group_name
  tags                = var.tags

  policy_settings = {
    mode                        = var.mode
    enabled                     = true
    request_body_check          = true
    max_request_body_size_in_kb = var.max_request_body_size_in_kb
    file_upload_limit_in_mb     = var.file_upload_limit_in_mb
  }
  managed_rules = {
    managed_rule_set = {
      owasp = {
        version = var.managed_rule_set_version
      }
    }
  }
  custom_rules     = local.custom_rules
  role_assignments = var.role_assignments
}
