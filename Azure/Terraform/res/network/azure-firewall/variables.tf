variable "name" {
  description = "Name of the firewall."
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

variable "sku_tier" {
  description = "Standard has network, application and NAT rules. Premium adds TLS inspection, IDPS and URL filtering. Basic is a smaller, cheaper SKU. Must be compatible with the tier of the attached firewall-policy module."
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.sku_tier)
    error_message = "Use Basic, Standard or Premium."
  }
}

variable "subnet_resource_id" {
  description = "Resource ID of the AzureFirewallSubnet subnet, at least /26. Create it with the virtual-network module; the subnet name is fixed by Azure, not something you choose."
  type        = string
}

variable "public_ip_resource_id" {
  description = "Resource ID of an existing public IP to use for outbound SNAT."
  type        = string
}

variable "firewall_policy_resource_id" {
  description = "Resource ID of a firewall policy from the firewall-policy module. Required in practice: without one, the firewall has no rules and blocks everything."
  type        = string
}

variable "availability_zones" {
  description = "Availability zones for the firewall, e.g. [\"1\", \"2\", \"3\"]. Leave empty for no zone pinning. Not available in every region."
  type        = list(string)
  default     = []
}

variable "diagnostics" {
  description = "Send diagnostic logs and metrics to a Log Analytics workspace. Leave null to skip diagnostics. An object (not a string) so its existence is known at plan time even when the workspace is created in the same apply."
  type = object({
    workspace_resource_id = string
  })
  default = null
}

variable "role_assignments" {
  description = "RBAC role assignments on the firewall, keyed by an arbitrary static name."
  type = map(object({
    role_definition_id_or_name = string
    principal_id               = string
    principal_type             = optional(string)
    description                = optional(string)
  }))
  default = {}
}
