variable "name" {
  description = "Name of the firewall policy."
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
  description = "Tags applied to the policy."
  type        = map(string)
  default     = {}
}

variable "sku" {
  description = "Standard has application/network/NAT rules. Premium adds TLS inspection, IDPS and URL filtering. Basic is a smaller, cheaper SKU with a lower rule and throughput ceiling."
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.sku)
    error_message = "Use Basic, Standard or Premium."
  }
}

variable "threat_intelligence_mode" {
  description = "Alert only logs matching traffic. Deny also blocks it. Off disables intrusion detection."
  type        = string
  default     = "Alert"

  validation {
    condition     = contains(["Off", "Alert", "Deny"], var.threat_intelligence_mode)
    error_message = "Use Off, Alert or Deny."
  }
}

variable "rule_collection_groups" {
  description = <<-EOT
    Rule collection groups, keyed by an arbitrary static name. Each group creates up to two Allow rule
    collections (one for network_rules, one for application_rules). The upstream AVM module for this resource
    does not create rule collection groups, so this module creates them directly with
    azurerm_firewall_policy_rule_collection_group.
  EOT
  type = map(object({
    priority = number
    network_rules = optional(map(object({
      priority              = number
      protocols             = list(string)
      source_addresses      = list(string)
      destination_addresses = list(string)
      destination_ports     = list(string)
    })), {})
    application_rules = optional(map(object({
      priority          = number
      source_addresses  = list(string)
      destination_fqdns = list(string)
      protocol_type     = string
      protocol_port     = number
    })), {})
  }))
  default = {}
}

variable "role_assignments" {
  description = "RBAC role assignments on the policy, keyed by an arbitrary static name."
  type = map(object({
    role_definition_id_or_name = string
    principal_id               = string
    principal_type             = optional(string)
    description                = optional(string)
  }))
  default = {}
}
