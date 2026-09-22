variable "name" {
  description = "Name of the container app. 2-32 characters, lowercase letters, numbers and hyphens, starting with a letter."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{0,30}[a-z0-9]$", var.name))
    error_message = "The name must be 2-32 characters, lowercase letters, numbers and hyphens, starting with a letter and ending with a letter or number."
  }
}

variable "resource_group_id" {
  description = "Resource ID of the resource group to deploy into, e.g. azurerm_resource_group.this.id."
  type        = string
}

variable "tags" {
  description = "Tags applied to the app."
  type        = map(string)
  default     = {}
}

variable "environment_resource_id" {
  description = "Resource ID of the Container Apps environment to run in."
  type        = string
}

variable "image" {
  description = "Container image, e.g. \"myregistry.azurecr.io/api:1.4.2\". Pin a tag or digest, not \"latest\"."
  type        = string
}

variable "container_name" {
  description = "Name of the container inside the app."
  type        = string
  default     = "main"
}

variable "cpu" {
  description = "CPU cores for the container, e.g. 0.25, 0.5, 1. Must pair with a valid memory value."
  type        = number
  default     = 0.5
}

variable "memory" {
  description = "Memory for the container, e.g. \"1Gi\". Must pair with a valid CPU value (memory is CPU x 2 on the Consumption profile)."
  type        = string
  default     = "1Gi"
}

variable "env" {
  description = "Environment variables for the container. Set either value or secret_name, not both. secret_name refers to a key of the secrets variable."
  type = list(object({
    name        = string
    value       = optional(string)
    secret_name = optional(string)
  }))
  default = []
}

variable "secrets" {
  description = <<-EOT
    Secrets read from Key Vault at runtime through a managed identity, keyed by the name the secret is known by inside the app
    (lowercase letters, numbers and hyphens).
    - key_vault_secret_id: secret URI in Key Vault. Omit the version to always use the latest.
    - identity: resource ID of the user-assigned identity used to read the secret, or "System" for the system-assigned identity.
      The identity must be attached to the app (user_assigned_identity_resource_ids) and have the "Key Vault Secrets User" role.
  EOT
  type = map(object({
    key_vault_secret_id = string
    identity            = string
  }))
  default = {}
}

variable "target_port" {
  description = "Port the container listens on. Ingress forwards to it."
  type        = number
  default     = 8080

  validation {
    condition     = var.target_port >= 1 && var.target_port <= 65535
    error_message = "Use a port between 1 and 65535."
  }
}

variable "ingress_external_enabled" {
  description = "Expose the app to the internet through the environment public endpoint. False by default: the app is reachable only inside the environment."
  type        = bool
  default     = false
}

variable "disable_ingress" {
  description = "Turn ingress off entirely, for background workers with no HTTP endpoint."
  type        = bool
  default     = false
}

variable "min_replicas" {
  description = "Minimum replicas. 0 scales to zero and adds cold-start latency."
  type        = number
  default     = 1

  validation {
    condition     = var.min_replicas >= 0 && var.min_replicas <= 1000
    error_message = "Use a value between 0 and 1000."
  }
}

variable "max_replicas" {
  description = "Maximum replicas."
  type        = number
  default     = 3

  validation {
    condition     = var.max_replicas >= 1 && var.max_replicas <= 1000
    error_message = "Use a value between 1 and 1000."
  }
}

variable "registry" {
  description = <<-EOT
    Private registry to pull the image from. Leave null for public images. An object (not separate strings) so its existence is
    known at plan time even when the registry is created in the same apply.
    - server: login server, e.g. "myregistry.azurecr.io".
    - identity_resource_id: user-assigned managed identity with the "AcrPull" role on the registry. A user-assigned identity is
      used because it exists before the app does, so the first revision can pull. It is attached to the app automatically.
  EOT
  type = object({
    server               = string
    identity_resource_id = string
  })
  default = null
}

variable "enable_system_assigned_identity" {
  description = "Enable the system-assigned managed identity."
  type        = bool
  default     = true
}

variable "user_assigned_identity_resource_ids" {
  description = "Resource IDs of additional user-assigned managed identities to attach, e.g. the identity used to read Key Vault secrets."
  type        = set(string)
  default     = []
}

variable "role_assignments" {
  description = "RBAC role assignments on the app, keyed by an arbitrary static name."
  type = map(object({
    role_definition_id_or_name = string
    principal_id               = string
    principal_type             = optional(string)
    description                = optional(string)
  }))
  default = {}
}
