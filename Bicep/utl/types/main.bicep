metadata name = 'Shared types'
metadata description = 'Types shared by the modules in this repo. Import with: import { roleAssignmentType } from "<relative path>/utl/types/main.bicep"'

@export()
@description('An Azure RBAC role assignment on the resource being deployed.')
type roleAssignmentType = {
  @description('Built-in role name (e.g. "Storage Blob Data Reader"), role GUID, or full role definition resource ID.')
  roleDefinitionIdOrName: string

  @description('Object ID of the principal receiving the role.')
  principalId: string

  @description('Type of the principal. Set it when assigning to a newly created identity to avoid replication delays.')
  principalType: ('ServicePrincipal' | 'User' | 'Group' | 'ForeignGroup' | 'Device')?

  @description('Description of the role assignment.')
  description: string?
}
