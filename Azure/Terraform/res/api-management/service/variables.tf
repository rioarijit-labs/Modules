variable "name" {
  description = "Name of the APIM instance. Globally unique, forms <name>.azure-api.net."
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

variable "publisher_email" {
  description = "Contact email for the API publisher (shown to API consumers)."
  type        = string
}

variable "publisher_name" {
  description = "Organization name shown in the developer portal."
  type        = string
}

variable "sku" {
  description = "Tier and capacity as \"<Tier>_<Capacity>\", e.g. \"Developer_1\". Developer has no SLA and no VNet integration but is inexpensive, a reasonable default for a showcase or dev environment. Standard/Basic add an SLA, still no VNet. Premium and the newer StandardV2/PremiumV2 SKUs support VNet integration and multi-region."
  type        = string
  default     = "Developer_1"
}

variable "virtual_network_type" {
  description = "External: APIM has a public IP with the gateway also reachable from the subnet. Internal: no public IP, gateway reachable only from the VNet. Premium or PremiumV2 only; leave None on other SKUs."
  type        = string
  default     = "None"

  validation {
    condition     = contains(["None", "External", "Internal"], var.virtual_network_type)
    error_message = "Use None, External or Internal."
  }
}

variable "subnet_resource_id" {
  description = "Subnet resource ID for VNet integration. Required when virtual_network_type is not None."
  type        = string
  default     = null
}

variable "apis" {
  description = "APIs to import from an OpenAPI specification, keyed by an arbitrary static name."
  type = map(object({
    display_name          = string
    path                  = string
    open_api_spec_url     = string
    subscription_required = optional(bool, true)
  }))
  default = {}
}

variable "public_network_access_enabled" {
  description = "Public network access to the management, portal and gateway endpoints. Only meaningful (and relevant to disable) on Premium/PremiumV2 with a private endpoint."
  type        = bool
  default     = true
}

variable "private_endpoint" {
  description = "Private endpoint for the management plane. Premium/PremiumV2 only. Leave null to skip. An object (not separate strings) so its existence is known at plan time even when the subnet is created in the same apply. private_dns_zone_resource_ids takes e.g. privatelink.azure-api.net."
  type = object({
    subnet_resource_id            = string
    private_dns_zone_resource_ids = optional(list(string), [])
  })
  default = null
}

variable "enable_system_assigned_identity" {
  description = "Enable the system-assigned managed identity, used for Key Vault-backed named values and certificates."
  type        = bool
  default     = true
}

variable "role_assignments" {
  description = "RBAC role assignments on the APIM resource (management plane), keyed by an arbitrary static name."
  type = map(object({
    role_definition_id_or_name = string
    principal_id               = string
    principal_type             = optional(string)
    description                = optional(string)
  }))
  default = {}
}
