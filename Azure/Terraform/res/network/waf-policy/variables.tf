variable "name" {
  description = "Name of the WAF policy."
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

variable "mode" {
  description = "Prevention blocks matching requests. Detection only logs them; use it to validate rules before switching to Prevention."
  type        = string
  default     = "Prevention"

  validation {
    condition     = contains(["Prevention", "Detection"], var.mode)
    error_message = "Use Prevention or Detection."
  }
}

variable "managed_rule_set_version" {
  description = "OWASP Core Rule Set version."
  type        = string
  default     = "3.2"
}

variable "max_request_body_size_in_kb" {
  description = "Maximum request body size the WAF inspects, in KB."
  type        = number
  default     = 128
}

variable "file_upload_limit_in_mb" {
  description = "Maximum file upload size the WAF allows, in MB."
  type        = number
  default     = 100
}

variable "custom_rules" {
  description = "Custom rules, keyed by an arbitrary static name, evaluated before the managed rule set."
  type = map(object({
    priority = number
    action   = string
    match_conditions = list(object({
      match_variables = list(object({
        variable_name = string
        selector      = optional(string)
      }))
      operator     = string
      match_values = list(string)
    }))
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
