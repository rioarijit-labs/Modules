locals {
  resource_group_name = element(split("/", var.resource_group_id), 4)
  is_linux            = var.os_type == "Linux"
  use_monitoring      = length(var.data_collection_rule_resource_ids) > 0

  default_image_reference = local.is_linux ? {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
    } : {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2025-datacenter-azure-edition"
    version   = "latest"
  }
  image_reference = var.image_reference == null ? local.default_image_reference : var.image_reference
  computer_name   = var.computer_name != null ? var.computer_name : (local.is_linux ? var.name : substr(var.name, 0, 15))

  data_disks = {
    for index, disk in var.data_disks : "disk_${index}" => {
      name                 = "${var.name}-data-${index}"
      lun                  = index
      disk_size_gb         = disk.disk_size_gb
      storage_account_type = disk.storage_account_type
      caching              = disk.caching
    }
  }

  nic_diagnostic_settings = var.diagnostics == null ? {} : {
    default = {
      workspace_resource_id = var.diagnostics.workspace_resource_id
    }
  }

  network_interfaces = {
    primary = {
      name                           = "nic-${var.name}-01"
      accelerated_networking_enabled = var.enable_accelerated_networking
      # No public IP: create_public_ip_address stays false
      ip_configurations = {
        primary = {
          name                          = "ipconfig01"
          private_ip_subnet_resource_id = var.subnet_resource_id
          private_ip_address_allocation = "Dynamic"
        }
      }
      network_security_groups = var.network_security_group == null ? {} : {
        default = {
          network_security_group_resource_id = var.network_security_group.resource_id
        }
      }
      diagnostic_settings = local.nic_diagnostic_settings
    }
  }

  entra_login_extension = var.enable_entra_id_login ? {
    entra_id_login = {
      name                       = local.is_linux ? "AADSSHLoginForLinux" : "AADLoginForWindows"
      publisher                  = "Microsoft.Azure.ActiveDirectory"
      type                       = local.is_linux ? "AADSSHLoginForLinux" : "AADLoginForWindows"
      type_handler_version       = local.is_linux ? "1.0" : "2.0"
      auto_upgrade_minor_version = true
    }
  } : {}

  monitoring_extension = local.use_monitoring ? {
    azure_monitor_agent = {
      name                       = local.is_linux ? "AzureMonitorLinuxAgent" : "AzureMonitorWindowsAgent"
      publisher                  = "Microsoft.Azure.Monitor"
      type                       = local.is_linux ? "AzureMonitorLinuxAgent" : "AzureMonitorWindowsAgent"
      type_handler_version       = "1.0"
      auto_upgrade_minor_version = true
      automatic_upgrade_enabled  = true
    }
  } : {}

  shutdown_schedules = var.auto_shutdown_time == null ? {} : {
    daily = {
      daily_recurrence_time = var.auto_shutdown_time
      timezone              = var.auto_shutdown_timezone
    }
  }
}

module "virtual_machine" {
  source  = "Azure/avm-res-compute-virtualmachine/azurerm"
  version = "0.21.0"

  name                = var.name
  location            = var.location
  resource_group_name = local.resource_group_name
  tags                = var.tags
  zone                = var.availability_zone
  os_type             = var.os_type
  sku_size            = var.sku_size
  computer_name       = local.computer_name

  source_image_reference = local.image_reference

  # Authentication: SSH key only on Linux, password on Windows. Nothing is generated.
  account_credentials = {
    admin_credentials = {
      username                           = var.admin_username
      password                           = local.is_linux ? null : var.admin_password
      ssh_keys                           = local.is_linux && var.ssh_public_key != null ? [var.ssh_public_key] : []
      generate_admin_password_or_ssh_key = false
    }
    password_authentication_disabled = local.is_linux
  }

  # Secure defaults
  secure_boot_enabled        = var.enable_trusted_launch
  vtpm_enabled               = var.enable_trusted_launch
  encryption_at_host_enabled = var.enable_encryption_at_host
  boot_diagnostics           = true
  patch_mode                 = var.patch_mode
  patch_assessment_mode      = var.patch_mode == "AutomaticByPlatform" ? "AutomaticByPlatform" : "ImageDefault"
  license_type               = !local.is_linux && var.enable_hybrid_benefit ? "Windows_Server" : null

  os_disk = {
    caching              = "ReadWrite"
    storage_account_type = var.os_disk_type
    disk_size_gb         = var.os_disk_size_gb
  }
  data_disk_managed_disks = local.data_disks
  network_interfaces      = local.network_interfaces

  managed_identities = {
    system_assigned            = var.enable_system_assigned_identity || var.enable_entra_id_login || local.use_monitoring
    user_assigned_resource_ids = var.user_assigned_identity_resource_ids
  }
  extensions         = merge(local.entra_login_extension, local.monitoring_extension)
  shutdown_schedules = local.shutdown_schedules
  role_assignments   = var.role_assignments
}

resource "azurerm_monitor_data_collection_rule_association" "this" {
  for_each = var.data_collection_rule_resource_ids

  name                    = "dcra-${each.key}"
  target_resource_id      = module.virtual_machine.resource_id
  data_collection_rule_id = each.value
}
