variable "name" {
  description = "Name of the gateway."
  type        = string
}

variable "location" {
  description = "Azure region, e.g. \"westeurope\"."
  type        = string
}

variable "resource_group_id" {
  description = "Resource ID of the resource group to deploy into, e.g. azurerm_resource_group.this.id."
  type        = string
}

variable "tags" {
  description = "Tags applied to all resources."
  type        = map(string)
  default     = {}
}

variable "sku_name" {
  description = "WAF_v2 includes the WAF policy support this module attaches. Standard_v2 has no WAF and is cheaper if you don't need one."
  type        = string
  default     = "WAF_v2"

  validation {
    condition     = contains(["WAF_v2", "Standard_v2"], var.sku_name)
    error_message = "Use WAF_v2 or Standard_v2."
  }
}

variable "autoscale_min_capacity" {
  description = "Minimum instance count for autoscaling. v2 SKUs always autoscale."
  type        = number
  default     = 0
}

variable "autoscale_max_capacity" {
  description = "Maximum autoscale capacity."
  type        = number
  default     = 10
}

variable "subnet_resource_id" {
  description = "Subnet resource ID for the gateway. Must be dedicated to Application Gateway, at least /27, with no other resources in it."
  type        = string
}

variable "public_ip_resource_id" {
  description = "Resource ID of a public IP address for an internet-facing frontend. Leave empty for a fully internal gateway (requires private_frontend_ip_address or a dynamic private IP in the subnet)."
  type        = string
  default     = ""
}

variable "private_frontend_ip_address" {
  description = "Static private IP address for the frontend, inside the gateway subnet. Leave empty for a dynamically assigned private IP."
  type        = string
  default     = ""
}

variable "firewall_policy_resource_id" {
  description = "Resource ID of a WAF policy from the waf-policy module. Required when sku_name is WAF_v2."
  type        = string
  default     = ""
}

variable "backends" {
  description = "Backend pools, keyed by pool name. ip_addresses and fqdns cannot both be set on the same pool."
  type = map(object({
    ip_addresses = optional(list(string), [])
    fqdns        = optional(list(string), [])
  }))

  validation {
    condition     = length(var.backends) > 0
    error_message = "Define at least one backend."
  }
}

variable "backend_settings" {
  description = <<-EOT
    How the gateway talks to a backend, keyed by an arbitrary static name.
    - protocol: Http or Https to the backend. Independent of whether clients reach the gateway over HTTP or HTTPS.
    - probe_path: path the gateway probes for backend health, e.g. "/healthz".
    - pick_host_name_from_backend_address: send the original Host header to a backend that expects it (e.g. an App Service), instead of the backend's own address.
  EOT
  type = map(object({
    port                                = number
    protocol                            = string
    probe_path                          = string
    pick_host_name_from_backend_address = optional(bool, false)
  }))

  validation {
    condition     = length(var.backend_settings) > 0
    error_message = "Define at least one backend setting."
  }
}

variable "listeners" {
  description = "What the gateway listens for on its frontend, keyed by an arbitrary static name. HTTP only in this module; host_name matches a specific site, leave null to match any host."
  type = map(object({
    port      = number
    host_name = optional(string)
  }))

  validation {
    condition     = length(var.listeners) > 0
    error_message = "Define at least one listener."
  }
}

variable "routing_rules" {
  description = "Routes a listener to a backend, keyed by an arbitrary static name. priority must be unique across all rules."
  type = map(object({
    priority             = number
    listener_name        = string
    backend_name         = string
    backend_setting_name = string
  }))

  validation {
    condition     = length(var.routing_rules) > 0
    error_message = "Define at least one routing rule."
  }
}

variable "diagnostics" {
  description = "Send diagnostic logs and metrics to a Log Analytics workspace (access and firewall logs). Leave null to skip diagnostics. An object (not a string) so its existence is known at plan time even when the workspace is created in the same apply."
  type = object({
    workspace_resource_id = string
  })
  default = null
}

variable "role_assignments" {
  description = "RBAC role assignments on the gateway, keyed by an arbitrary static name."
  type = map(object({
    role_definition_id_or_name = string
    principal_id               = string
    principal_type             = optional(string)
    description                = optional(string)
  }))
  default = {}
}
