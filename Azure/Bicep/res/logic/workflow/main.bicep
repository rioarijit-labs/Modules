metadata name = 'Logic App (Consumption)'
metadata description = 'Consumption-tier Logic App workflow: pay-per-execution, designer-based, for orchestrating connectors and approvals (wraps AVM).'

import { roleAssignmentType } from '../../../utl/types/main.bicep'

@description('Name of the workflow.')
@minLength(1)
@maxLength(80)
param name string

@description('Azure region. Defaults to the resource group location.')
param location string = resourceGroup().location

@description('Tags applied to the workflow.')
param tags object = {}

@description('Trigger definitions, in Workflow Definition Language, e.g. { manual: { type: "Request", kind: "Http", inputs: { schema: {} } } }. Free-form: Logic Apps has no fixed schema for this, it is whatever the designer or the Workflow Definition Language documentation describes.')
param triggers object = {}

@description('Action definitions, in Workflow Definition Language.')
param actions object = {}

@description('Workflow-level parameters (Workflow Definition Language "parameters" block), referenced from triggers/actions with @parameters(\'name\').')
param workflowParameters object = {}

@description('Enabled runs the workflow on its triggers. Disabled keeps the resource but stops it running, useful while you finish wiring connections.')
@allowed([
  'Enabled'
  'Disabled'
])
param state string = 'Enabled'

@description('Log Analytics workspace resource ID for diagnostic settings (trigger and action run history, useful for alerting on failed runs). Leave empty to skip diagnostics.')
param diagnosticsWorkspaceResourceId string = ''

@description('Enable the system-assigned managed identity, used by connectors that authenticate with Entra ID (e.g. the Azure Blob, Key Vault or HTTP-with-managed-identity connectors) instead of a connection secret.')
param enableSystemAssignedIdentity bool = true

@description('Resource IDs of user-assigned managed identities to attach.')
param userAssignedIdentityResourceIds string[] = []

@description('RBAC role assignments on the workflow resource (management plane, e.g. "Logic App Contributor"). Grant the workflow\'s own identity roles on the resources it calls separately, through those resources\' roleAssignments.')
param roleAssignments roleAssignmentType[] = []

module workflow 'br/public:avm/res/logic/workflow:0.6.0' = {
  name: '${take(name, 40)}-avm'
  params: {
    name: name
    location: location
    tags: tags
    state: state
    workflowTriggers: triggers
    workflowActions: actions
    workflowParameters: workflowParameters
    managedIdentities: {
      systemAssigned: enableSystemAssignedIdentity
      userAssignedResourceIds: userAssignedIdentityResourceIds
    }
    diagnosticSettings: empty(diagnosticsWorkspaceResourceId)
      ? []
      : [
          { workspaceResourceId: diagnosticsWorkspaceResourceId }
        ]
    roleAssignments: roleAssignments
  }
}

@description('Resource ID of the workflow.')
output resourceId string = workflow.outputs.resourceId

@description('Name of the workflow.')
output name string = workflow.outputs.name

@description('Principal ID of the system-assigned identity. Empty when not enabled.')
output systemAssignedMIPrincipalId string = workflow.outputs.?systemAssignedMIPrincipalId ?? ''
