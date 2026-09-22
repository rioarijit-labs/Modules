variable "name" {
  description = "Name of the Front Door profile."
  type        = string
}

variable "resource_group_id" {
  description = "Resource ID of the resource group to deploy into, e.g. azurerm_resource_group.this.id. Front Door is a global resource; only used to derive the resource group name."
  type        = string
}

variable "tags" {
  description = "Tags applied to all resources."
  type        = map(string)
  default     = {}
}

variable "sku" {
  description = "Standard is CDN plus global load balancing. Premium adds a WAF-capable security layer, private link to origins and bot protection."
  type        = string
  default     = "Standard_AzureFrontDoor"

  validation {
    condition     = contains(["Standard_AzureFrontDoor", "Premium_AzureFrontDoor"], var.sku)
    error_message = "Use Standard_AzureFrontDoor or Premium_AzureFrontDoor."
  }
}

variable "endpoint_name" {
  description = "Name of the public endpoint. Forms <endpoint_name>-<hash>.z01.azurefd.net unless a custom domain is added. Defaults to the profile name."
  type        = string
  default     = null
}

variable "origins" {
  description = "Origins in the single origin group this module creates, keyed by an arbitrary static name. Front Door probes each and routes only to healthy ones."
  type = map(object({
    host_name = string
    priority  = optional(number, 1)
    weight    = optional(number, 1000)
  }))

  validation {
    condition     = length(var.origins) > 0
    error_message = "Define at least one origin."
  }
}

variable "health_probe_path" {
  description = "Path Front Door requests to check origin health, e.g. \"/healthz\"."
  type        = string
  default     = "/"
}

variable "origin_protocol" {
  description = "Protocol used between Front Door and the origins."
  type        = string
  default     = "Https"

  validation {
    condition     = contains(["Http", "Https"], var.origin_protocol)
    error_message = "Use Http or Https."
  }
}

variable "route_patterns" {
  description = "URL path patterns this route matches, e.g. [\"/*\"] for everything."
  type        = list(string)
  default     = ["/*"]
}

variable "custom_domain_names" {
  description = "Custom domain names to bind, e.g. [\"www.example.com\"]. DNS (a CNAME to the endpoint, or an ALIAS/ANAME at the zone apex) must already point at Front Door; this only registers the binding and requests the managed TLS certificate."
  type        = list(string)
  default     = []
}

variable "enable_system_assigned_identity" {
  description = "Enable the system-assigned managed identity, needed for Key Vault-sourced TLS certificates on custom domains."
  type        = bool
  default     = false
}

variable "role_assignments" {
  description = "RBAC role assignments on the profile, keyed by an arbitrary static name."
  type = map(object({
    role_definition_id_or_name = string
    principal_id               = string
    principal_type             = optional(string)
    description                = optional(string)
  }))
  default = {}
}
