locals {
  resource_group_name     = element(split("/", var.resource_group_id), 4)
  effective_endpoint_name = coalesce(var.endpoint_name, var.name)

  origin_groups = {
    default = {
      name = "default"
      load_balancing = {
        default = {}
      }
      health_probe = {
        default = {
          protocol            = var.origin_protocol
          path                = var.health_probe_path
          interval_in_seconds = 30
        }
      }
    }
  }

  origins = {
    for origin_name, origin in var.origins : origin_name => {
      name                           = origin_name
      origin_group_key               = "default"
      host_name                      = origin.host_name
      certificate_name_check_enabled = "true"
      priority                       = origin.priority
      weight                         = origin.weight
    }
  }

  endpoints = {
    default = {
      name = local.effective_endpoint_name
    }
  }

  routes = {
    default = {
      name                   = "default"
      origin_group_key       = "default"
      origin_keys            = keys(local.origins)
      endpoint_key           = "default"
      forwarding_protocol    = var.origin_protocol == "Https" ? "HttpsOnly" : "HttpOnly"
      supported_protocols    = ["Http", "Https"]
      patterns_to_match      = var.route_patterns
      https_redirect_enabled = true
      link_to_default_domain = true
      custom_domain_keys     = keys(local.custom_domains)
    }
  }

  custom_domains = {
    for domain_name in var.custom_domain_names : replace(domain_name, ".", "-") => {
      name      = replace(domain_name, ".", "-")
      host_name = domain_name
      tls = {
        certificate_type = "ManagedCertificate"
      }
    }
  }
}

module "front_door_profile" {
  source  = "Azure/avm-res-cdn-profile/azurerm"
  version = "0.1.9"

  name                = var.name
  location            = "global"
  resource_group_name = local.resource_group_name
  tags                = var.tags
  sku                 = var.sku

  front_door_origin_groups  = local.origin_groups
  front_door_origins        = local.origins
  front_door_endpoints      = local.endpoints
  front_door_routes         = local.routes
  front_door_custom_domains = local.custom_domains

  managed_identities = {
    system_assigned = var.enable_system_assigned_identity
  }
  role_assignments = var.role_assignments
}
