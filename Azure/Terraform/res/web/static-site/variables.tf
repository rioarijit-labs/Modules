variable "name" {
  description = "Name of the static web app. 2-40 characters. Forms the default <name>.<region>.azurestaticapps.net hostname unless a custom domain is added."
  type        = string

  validation {
    condition     = length(var.name) >= 2 && length(var.name) <= 40
    error_message = "The name must be 2-40 characters."
  }
}

variable "location" {
  description = "Azure region. Static Web Apps deploy to a smaller set of regions than most services; check availability first."
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

variable "sku" {
  description = "Free has no SLA, no custom auth providers and no private endpoint. Standard is required for a private endpoint, staging environments beyond the free limit and a support SLA."
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Free", "Standard"], var.sku)
    error_message = "Use Free or Standard."
  }
}

variable "public_network_access_enabled" {
  description = "Unlike most modules in this repo, this defaults to true: a static site is usually meant to be reached over the public internet, and Standard-only features like custom domains and the managed CDN assume that. Set to false, and add a private endpoint, for an internal-only site."
  type        = bool
  default     = true
}

variable "private_endpoint" {
  description = "Private endpoint for the app. Standard SKU only. Leave null to skip. An object (not separate strings) so its existence is known at plan time even when the subnet is created in the same apply. private_dns_zone_resource_ids takes e.g. privatelink.azurestaticapps.net."
  type = object({
    subnet_resource_id            = string
    private_dns_zone_resource_ids = optional(list(string), [])
  })
  default = null
}

variable "custom_domain_names" {
  description = "Custom domain names to bind to the app, e.g. [\"www.example.com\"]. DNS must already point at the app; this only registers the binding, and does not manage DNS records."
  type        = list(string)
  default     = []
}

variable "app_settings" {
  description = "Application settings, available to the API functions at runtime. Use Key Vault references (@Microsoft.KeyVault(...)) for secrets, never plain values."
  type        = map(string)
  default     = {}
}

variable "enable_system_assigned_identity" {
  description = "Enable the system-assigned managed identity, used by managed functions to reach other resources."
  type        = bool
  default     = false
}

variable "role_assignments" {
  description = "RBAC role assignments on the app, keyed by an arbitrary static name, e.g. \"Contributor\" for a deployment identity."
  type = map(object({
    role_definition_id_or_name = string
    principal_id               = string
    principal_type             = optional(string)
    description                = optional(string)
  }))
  default = {}
}
