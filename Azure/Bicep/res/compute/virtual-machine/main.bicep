metadata name = 'Virtual machine'
metadata description = 'Secure-by-default Linux or Windows virtual machine: no public IP, Entra ID login, trusted launch, encryption at host and platform patching (wraps AVM).'

import { roleAssignmentType } from '../../../utl/types/main.bicep'

@export()
@description('Image to deploy. Set publisher, offer, sku and version for a marketplace image, or id for a gallery or managed image.')
type imageReferenceType = {
  @description('Marketplace publisher, e.g. "Canonical".')
  publisher: string?

  @description('Marketplace offer, e.g. "ubuntu-24_04-lts".')
  offer: string?

  @description('Marketplace SKU, e.g. "server". Use a Generation 2 SKU: trusted launch needs it.')
  sku: string?

  @description('Image version. Use "latest" or pin an exact version.')
  version: string?

  @description('Resource ID of a Compute Gallery image version or managed image. Use instead of the marketplace fields.')
  id: string?
}

@export()
@description('An empty managed data disk to attach.')
type dataDiskType = {
  @description('Size of the disk in GB.')
  @minValue(1)
  @maxValue(32767)
  diskSizeGB: int

  @description('Disk type. Defaults to Premium_LRS.')
  storageAccountType: ('Premium_LRS' | 'Premium_ZRS' | 'StandardSSD_LRS' | 'StandardSSD_ZRS' | 'Standard_LRS')?

  @description('Host caching. Defaults to ReadOnly. Use None for write-heavy disks such as logs.')
  caching: ('None' | 'ReadOnly' | 'ReadWrite')?
}

@description('Name of the virtual machine resource. 1-64 characters. Windows computer names are truncated to 15 characters unless computerName is set.')
@minLength(1)
@maxLength(64)
param name string

@description('Azure region. Defaults to the resource group location.')
param location string = resourceGroup().location

@description('Tags applied to all resources.')
param tags object = {}

@description('Operating system.')
@allowed([
  'Linux'
  'Windows'
])
param osType string = 'Linux'

@description('VM size. The default supports Generation 2 images, trusted launch, encryption at host and accelerated networking.')
param vmSize string = 'Standard_D2s_v5'

@description('Image to deploy. Leave unset for the default: Ubuntu 24.04 LTS for Linux, Windows Server 2025 Datacenter Azure Edition for Windows.')
param imageReference imageReferenceType?

@description('Resource ID of the subnet the network interface is placed in.')
param subnetResourceId string

@description('Resource ID of a network security group to attach to the network interface. Leave empty to rely on the subnet NSG.')
param networkSecurityGroupResourceId string = ''

@description('Availability zone: 1, 2 or 3, or -1 for a regional VM with no zone. Use -1 in regions without zones.')
@allowed([
  -1
  1
  2
  3
])
param availabilityZone int = 1

@description('Administrator user name. Windows rejects reserved names such as "admin" and "administrator".')
param adminUsername string = 'azureadmin'

@description('Administrator password. Required for Windows, ignored for Linux. Read it from Key Vault, never hard-code it.')
@secure()
param adminPassword string = ''

@description('SSH public key (e.g. the contents of id_ed25519.pub). Required for Linux, ignored for Windows. Password login is disabled on Linux.')
param sshPublicKey string = ''

@description('Computer name inside the OS. Defaults to the VM name, truncated to 15 characters on Windows.')
param computerName string = ''

@description('Size of the OS disk in GB. Leave unset to use the image default.')
param osDiskSizeGB int?

@description('OS disk type.')
@allowed([
  'Premium_LRS'
  'Premium_ZRS'
  'StandardSSD_LRS'
  'StandardSSD_ZRS'
  'Standard_LRS'
])
param osDiskType string = 'Premium_LRS'

@description('Empty data disks to create and attach, in LUN order.')
param dataDisks dataDiskType[] = []

@description('Enable trusted launch: secure boot and a virtual TPM. Needs a Generation 2 image.')
param enableTrustedLaunch bool = true

@description('Encrypt temp disks and disk caches on the host. The subscription needs the EncryptionAtHost feature: az feature register --namespace Microsoft.Compute --name EncryptionAtHost.')
param enableEncryptionAtHost bool = true

@description('Enable accelerated networking. The VM size must support it.')
param enableAcceleratedNetworking bool = true

@description('Sign in with Microsoft Entra ID, using the AADSSHLoginForLinux or AADLoginForWindows extension. Grant "Virtual Machine Administrator Login" or "Virtual Machine User Login" through roleAssignments.')
param enableEntraIdLogin bool = true

@description('Enable the system-assigned managed identity. Always on when Entra ID login or the monitoring agent is enabled.')
param enableSystemAssignedIdentity bool = true

@description('Resource IDs of user-assigned managed identities to attach.')
param userAssignedIdentityResourceIds string[] = []

@description('Resource IDs of data collection rules. When set, the Azure Monitor Agent is installed and associated with each rule.')
param dataCollectionRuleResourceIds string[] = []

@description('How the platform patches the OS. AutomaticByPlatform needs a supported image and orchestrates patches across zones safely.')
@allowed([
  'AutomaticByPlatform'
  'AutomaticByOS'
  'ImageDefault'
  'Manual'
])
param patchMode string = 'AutomaticByPlatform'

@description('Apply Azure Hybrid Benefit for Windows Server. Only enable it when you own eligible licenses.')
param enableHybridBenefit bool = false

@description('Daily auto-shutdown time as HHmm in autoShutdownTimeZone, e.g. "1900". Leave empty to disable. Useful for labs.')
param autoShutdownTime string = ''

@description('Windows time zone name for auto-shutdown, e.g. "UTC" or "W. Europe Standard Time".')
param autoShutdownTimeZone string = 'UTC'

@description('Log Analytics workspace resource ID for the network interface diagnostic settings. Leave empty to skip. OS-level logs and metrics come from the Azure Monitor Agent through dataCollectionRuleResourceIds.')
param diagnosticsWorkspaceResourceId string = ''

@description('RBAC role assignments on the VM, e.g. "Virtual Machine Administrator Login" for an admin group.')
param roleAssignments roleAssignmentType[] = []

var isLinux = osType == 'Linux'
var defaultImageReference = isLinux
  ? {
      publisher: 'Canonical'
      offer: 'ubuntu-24_04-lts'
      sku: 'server'
      version: 'latest'
    }
  : {
      publisher: 'MicrosoftWindowsServer'
      offer: 'WindowsServer'
      sku: '2025-datacenter-azure-edition'
      version: 'latest'
    }
var effectiveComputerName = !empty(computerName) ? computerName : (isLinux ? name : take(name, 15))
var useMonitoringAgent = !empty(dataCollectionRuleResourceIds)
var dataCollectionRuleAssociations = [
  for (ruleResourceId, i) in dataCollectionRuleResourceIds: {
    name: 'dcra-${i}'
    dataCollectionRuleResourceId: ruleResourceId
  }
]
var dataDisksToAttach = [
  for (disk, i) in dataDisks: {
    lun: i
    diskSizeGB: disk.diskSizeGB
    caching: disk.?caching ?? 'ReadOnly'
    createOption: 'Empty'
    deleteOption: 'Delete'
    managedDisk: {
      storageAccountType: disk.?storageAccountType ?? 'Premium_LRS'
    }
  }
]

module virtualMachine 'br/public:avm/res/compute/virtual-machine:0.22.3' = {
  name: '${take(name, 40)}-avm'
  params: {
    name: name
    computerName: effectiveComputerName
    location: location
    tags: tags
    osType: osType
    vmSize: vmSize
    availabilityZone: availabilityZone
    imageReference: imageReference ?? defaultImageReference
    // Authentication: SSH key only on Linux, password on Windows
    adminUsername: adminUsername
    adminPassword: adminPassword
    disablePasswordAuthentication: isLinux
    publicKeys: isLinux && !empty(sshPublicKey)
      ? [
          {
            keyData: sshPublicKey
            path: '/home/${adminUsername}/.ssh/authorized_keys'
          }
        ]
      : []
    // Secure defaults
    securityType: enableTrustedLaunch ? 'TrustedLaunch' : null
    secureBootEnabled: enableTrustedLaunch
    vTpmEnabled: enableTrustedLaunch
    encryptionAtHost: enableEncryptionAtHost
    bootDiagnostics: true
    patchMode: patchMode
    patchAssessmentMode: patchMode == 'AutomaticByPlatform' ? 'AutomaticByPlatform' : 'ImageDefault'
    licenseType: !isLinux && enableHybridBenefit ? 'Windows_Server' : null
    osDisk: {
      createOption: 'FromImage'
      deleteOption: 'Delete'
      caching: 'ReadWrite'
      diskSizeGB: osDiskSizeGB
      managedDisk: {
        storageAccountType: osDiskType
      }
    }
    dataDisks: dataDisksToAttach
    nicConfigurations: [
      {
        nicSuffix: '-nic-01'
        deleteOption: 'Delete'
        enableAcceleratedNetworking: enableAcceleratedNetworking
        networkSecurityGroupResourceId: empty(networkSecurityGroupResourceId) ? null : networkSecurityGroupResourceId
        // No pipConfiguration: the VM has no public IP
        ipConfigurations: [
          {
            name: 'ipconfig01'
            subnetResourceId: subnetResourceId
            privateIPAllocationMethod: 'Dynamic'
          }
        ]
        diagnosticSettings: empty(diagnosticsWorkspaceResourceId)
          ? []
          : [
              { workspaceResourceId: diagnosticsWorkspaceResourceId }
            ]
      }
    ]
    // Identity and extensions
    managedIdentities: {
      systemAssigned: enableSystemAssignedIdentity || enableEntraIdLogin || useMonitoringAgent
      userAssignedResourceIds: userAssignedIdentityResourceIds
    }
    extensionAadJoinConfig: {
      enabled: enableEntraIdLogin
    }
    extensionMonitoringAgentConfig: {
      enabled: useMonitoringAgent
      dataCollectionRuleAssociations: dataCollectionRuleAssociations
    }
    autoShutdownConfig: empty(autoShutdownTime)
      ? {}
      : {
          status: 'Enabled'
          dailyRecurrenceTime: autoShutdownTime
          timeZone: autoShutdownTimeZone
          notificationStatus: 'Disabled'
        }
    roleAssignments: roleAssignments
  }
}

@description('Resource ID of the virtual machine.')
output resourceId string = virtualMachine.outputs.resourceId

@description('Name of the virtual machine.')
output name string = virtualMachine.outputs.name

@description('Principal ID of the system-assigned identity. Empty when not enabled.')
output systemAssignedMIPrincipalId string = virtualMachine.outputs.?systemAssignedMIPrincipalId ?? ''
