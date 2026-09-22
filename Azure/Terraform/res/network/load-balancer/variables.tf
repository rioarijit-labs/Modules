variable "name" {
  description = "Name of the load balancer."
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
  description = "Tags applied to the load balancer."
  type        = map(string)
  default     = {}
}

variable "sku_name" {
  description = "Standard is required for zone redundancy and is the only tier with a security-by-default posture (Basic allows all traffic by default with no NSG needed, which is easy to get wrong)."
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Basic", "Standard"], var.sku_name)
    error_message = "Use Basic or Standard."
  }
}

variable "subnet_resource_id" {
  description = "Subnet resource ID for the frontend IP. This module always creates an internal (private) load balancer, never a public one."
  type        = string
}

variable "frontend_private_ip_address" {
  description = "Static private IP address for the frontend. Leave empty for a dynamically assigned address."
  type        = string
  default     = ""
}

variable "backend_pool_names" {
  description = "Names of the backend pools to create. Add instances to a pool from the VM or VMSS side after deployment."
  type        = list(string)

  validation {
    condition     = length(var.backend_pool_names) > 0
    error_message = "Define at least one backend pool."
  }
}

variable "probes" {
  description = "Health probes, keyed by an arbitrary static name."
  type = map(object({
    protocol            = string
    port                = number
    request_path        = optional(string)
    interval_in_seconds = optional(number, 15)
    number_of_probes    = optional(number, 2)
  }))
  default = {}
}

variable "load_balancing_rules" {
  description = "Load balancing rules, keyed by an arbitrary static name."
  type = map(object({
    protocol          = string
    frontend_port     = number
    backend_port      = number
    backend_pool_name = string
    probe_name        = string
  }))
  default = {}
}

variable "diagnostics" {
  description = "Send diagnostic logs and metrics to a Log Analytics workspace. Leave null to skip diagnostics. An object (not a string) so its existence is known at plan time even when the workspace is created in the same apply."
  type = object({
    workspace_resource_id = string
  })
  default = null
}

variable "role_assignments" {
  description = "RBAC role assignments on the load balancer, keyed by an arbitrary static name."
  type = map(object({
    role_definition_id_or_name = string
    principal_id               = string
    principal_type             = optional(string)
    description                = optional(string)
  }))
  default = {}
}
