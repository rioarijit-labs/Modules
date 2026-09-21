variable "name" {
  description = "Name of the virtual machine resource. 1-64 characters. Windows computer names are truncated to 15 characters unless computer_name is set."
  type        = string

  validation {
    condition     = length(var.name) >= 1 && length(var.name) <= 64
    error_message = "The name must be 1-64 characters."
  }
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

variable "os_type" {
  description = "Operating system."
  type        = string
  default     = "Linux"

  validation {
    condition     = contains(["Linux", "Windows"], var.os_type)
    error_message = "Use Linux or Windows."
  }
}

variable "sku_size" {
  description = "VM size. The default supports Generation 2 images, trusted launch, encryption at host and accelerated networking."
  type        = string
  default     = "Standard_D2s_v5"
}

variable "image_reference" {
  description = "Marketplace image to deploy. Leave null for the default: Ubuntu 24.04 LTS for Linux, Windows Server 2025 Datacenter Azure Edition for Windows. Use a Generation 2 SKU: trusted launch needs it."
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
  default = null
}

variable "subnet_resource_id" {
  description = "Resource ID of the subnet the network interface is placed in."
  type        = string
}

variable "network_security_group" {
  description = "Network security group to attach to the network interface. Leave null to rely on the subnet NSG. An object (not a string) so its existence is known at plan time even when the NSG is created in the same apply."
  type = object({
    resource_id = string
  })
  default = null
}

variable "availability_zone" {
  description = "Availability zone: \"1\", \"2\" or \"3\", or null for a regional VM with no zone. Use null in regions without zones."
  type        = string
  default     = "1"

  validation {
    condition     = var.availability_zone == null || contains(["1", "2", "3"], coalesce(var.availability_zone, "1"))
    error_message = "Use \"1\", \"2\", \"3\" or null."
  }
}

variable "admin_username" {
  description = "Administrator user name. Windows rejects reserved names such as \"admin\" and \"administrator\"."
  type        = string
  default     = "azureadmin"
}

variable "admin_password" {
  description = "Administrator password. Required for Windows, ignored for Linux. Read it from Key Vault, never hard-code it."
  type        = string
  default     = null
  sensitive   = true
}

variable "ssh_public_key" {
  description = "SSH public key (e.g. the contents of id_ed25519.pub). Required for Linux, ignored for Windows. Password login is disabled on Linux."
  type        = string
  default     = null
}

variable "computer_name" {
  description = "Computer name inside the OS. Defaults to the VM name, truncated to 15 characters on Windows."
  type        = string
  default     = null
}

variable "os_disk_size_gb" {
  description = "Size of the OS disk in GB. Leave null to use the image default."
  type        = number
  default     = null
}

variable "os_disk_type" {
  description = "OS disk type."
  type        = string
  default     = "Premium_LRS"

  validation {
    condition     = contains(["Premium_LRS", "Premium_ZRS", "StandardSSD_LRS", "StandardSSD_ZRS", "Standard_LRS"], var.os_disk_type)
    error_message = "Use Premium_LRS, Premium_ZRS, StandardSSD_LRS, StandardSSD_ZRS or Standard_LRS."
  }
}

variable "data_disks" {
  description = <<-EOT
    Empty data disks to create and attach, in LUN order.
    - disk_size_gb: size of the disk in GB.
    - storage_account_type: defaults to Premium_LRS.
    - caching: None, ReadOnly or ReadWrite. Defaults to ReadOnly. Use None for write-heavy disks such as logs.
  EOT
  type = list(object({
    disk_size_gb         = number
    storage_account_type = optional(string, "Premium_LRS")
    caching              = optional(string, "ReadOnly")
  }))
  default = []
}

variable "enable_trusted_launch" {
  description = "Enable trusted launch: secure boot and a virtual TPM. Needs a Generation 2 image."
  type        = bool
  default     = true
}

variable "enable_encryption_at_host" {
  description = "Encrypt temp disks and disk caches on the host. The subscription needs the EncryptionAtHost feature: az feature register --namespace Microsoft.Compute --name EncryptionAtHost."
  type        = bool
  default     = true
}

variable "enable_accelerated_networking" {
  description = "Enable accelerated networking. The VM size must support it."
  type        = bool
  default     = true
}

variable "enable_entra_id_login" {
  description = "Sign in with Microsoft Entra ID, using the AADSSHLoginForLinux or AADLoginForWindows extension. Grant \"Virtual Machine Administrator Login\" or \"Virtual Machine User Login\" through role_assignments."
  type        = bool
  default     = true
}

variable "enable_system_assigned_identity" {
  description = "Enable the system-assigned managed identity. Always on when Entra ID login or the monitoring agent is enabled."
  type        = bool
  default     = true
}

variable "user_assigned_identity_resource_ids" {
  description = "Resource IDs of user-assigned managed identities to attach."
  type        = set(string)
  default     = []
}

variable "data_collection_rule_resource_ids" {
  description = "Data collection rules, keyed by an arbitrary static name. When set, the Azure Monitor Agent is installed and associated with each rule."
  type        = map(string)
  default     = {}
}

variable "patch_mode" {
  description = "How the platform patches the OS. AutomaticByPlatform needs a supported image and orchestrates patches across zones safely. AutomaticByOS and Manual are Windows only."
  type        = string
  default     = "AutomaticByPlatform"

  validation {
    condition     = contains(["AutomaticByPlatform", "AutomaticByOS", "ImageDefault", "Manual"], var.patch_mode)
    error_message = "Use AutomaticByPlatform, AutomaticByOS, ImageDefault or Manual."
  }
}

variable "enable_hybrid_benefit" {
  description = "Apply Azure Hybrid Benefit for Windows Server. Only enable it when you own eligible licenses."
  type        = bool
  default     = false
}

variable "auto_shutdown_time" {
  description = "Daily auto-shutdown time as HHmm in auto_shutdown_timezone, e.g. \"1900\". Leave null to disable. Useful for labs."
  type        = string
  default     = null
}

variable "auto_shutdown_timezone" {
  description = "Windows time zone name for auto-shutdown, e.g. \"UTC\" or \"W. Europe Standard Time\"."
  type        = string
  default     = "UTC"
}

variable "diagnostics" {
  description = "Send the network interface metrics to a Log Analytics workspace. Leave null to skip. OS-level logs and metrics come from the Azure Monitor Agent through data_collection_rule_resource_ids. An object (not a string) so its existence is known at plan time even when the workspace is created in the same apply."
  type = object({
    workspace_resource_id = string
  })
  default = null
}

variable "role_assignments" {
  description = "RBAC role assignments on the VM, keyed by an arbitrary static name, e.g. \"Virtual Machine Administrator Login\" for an admin group."
  type = map(object({
    role_definition_id_or_name = string
    principal_id               = string
    principal_type             = optional(string)
    description                = optional(string)
  }))
  default = {}
}
