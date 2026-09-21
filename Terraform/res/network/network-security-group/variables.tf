variable "name" {
  description = "Name of the network security group."
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
  description = "Tags applied to the network security group."
  type        = map(string)
  default     = {}
}

variable "security_rules" {
  description = <<-EOT
    Security rules, keyed by an arbitrary static name. Set exactly one of each source/destination
    prefix and port pair (singular or plural form). Priority is 100-4096 and must be unique per direction.
  EOT
  type = map(object({
    name                         = string
    access                       = string
    direction                    = string
    priority                     = number
    protocol                     = string
    description                  = optional(string)
    source_address_prefix        = optional(string)
    source_address_prefixes      = optional(set(string))
    source_port_range            = optional(string)
    source_port_ranges           = optional(set(string))
    destination_address_prefix   = optional(string)
    destination_address_prefixes = optional(set(string))
    destination_port_range       = optional(string)
    destination_port_ranges      = optional(set(string))
  }))
  default = {}

  validation {
    condition = alltrue([
      for rule in values(var.security_rules) :
      contains(["Allow", "Deny"], rule.access) &&
      contains(["Inbound", "Outbound"], rule.direction) &&
      contains(["*", "Tcp", "Udp", "Icmp", "Ah", "Esp"], rule.protocol) &&
      rule.priority >= 100 && rule.priority <= 4096
    ])
    error_message = "Each rule needs access Allow|Deny, direction Inbound|Outbound, protocol *|Tcp|Udp|Icmp|Ah|Esp and a priority between 100 and 4096."
  }
}

variable "deny_all_inbound" {
  description = "Add an explicit inbound deny-all rule at priority 4096, so the intent is visible in the portal and in reviews. It also blocks inbound VNet traffic and load balancer probes that Azure's default rules allow, so add allow rules below 4096 for whatever must reach the subnet."
  type        = bool
  default     = true
}

variable "diagnostics" {
  description = "Send diagnostic logs to a Log Analytics workspace. Leave null to skip diagnostics. An object (not a string) so its existence is known at plan time even when the workspace is created in the same apply."
  type = object({
    workspace_resource_id = string
  })
  default = null
}
