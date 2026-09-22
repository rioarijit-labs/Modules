metadata name = 'User-assigned managed identity'
metadata description = 'User-assigned managed identity, optionally federated for workload identity (Kubernetes, GitHub Actions) (wraps AVM).'

import { roleAssignmentType } from '../../../utl/types/main.bicep'

@export()
@description('A federated identity credential, trusting tokens from an external OIDC issuer (e.g. a Kubernetes service account or a GitHub Actions workflow) without a client secret.')
type federatedCredentialType = {
  @description('Name of the credential.')
  name: string

  @description('Token issuer URL, e.g. the AKS OIDC issuer URL or "https://token.actions.githubusercontent.com" for GitHub Actions.')
  issuer: string

  @description('Expected subject claim, e.g. "system:serviceaccount:<namespace>:<service-account>" for Kubernetes, or "repo:<org>/<repo>:ref:refs/heads/main" for GitHub Actions.')
  subject: string

  @description('Expected audience claims. Defaults to ["api://AzureADTokenExchange"] if left empty, the standard audience for Entra workload identity federation.')
  audiences: string[]
}

@description('Name of the managed identity.')
param name string

@description('Azure region. Defaults to the resource group location.')
param location string = resourceGroup().location

@description('Tags applied to the identity.')
param tags object = {}

@description('Federated identity credentials to create, e.g. for AKS workload identity or GitHub Actions OIDC login.')
param federatedIdentityCredentials federatedCredentialType[] = []

@description('RBAC role assignments granted to this identity on the resources you deploy alongside it, e.g. "Storage Blob Data Contributor" scoped by the caller.')
param roleAssignments roleAssignmentType[] = []

module userAssignedIdentity 'br/public:avm/res/managed-identity/user-assigned-identity:0.6.0' = {
  name: '${take(name, 40)}-avm'
  params: {
    name: name
    location: location
    tags: tags
    federatedIdentityCredentials: [
      for credential in federatedIdentityCredentials: {
        name: credential.name
        issuer: credential.issuer
        subject: credential.subject
        audiences: empty(credential.audiences) ? ['api://AzureADTokenExchange'] : credential.audiences
      }
    ]
    roleAssignments: roleAssignments
  }
}

@description('Resource ID of the managed identity. Pass this to another module\'s userAssignedIdentityResourceIds.')
output resourceId string = userAssignedIdentity.outputs.resourceId

@description('Name of the managed identity.')
output name string = userAssignedIdentity.outputs.name

@description('Principal (object) ID, used in role assignments.')
output principalId string = userAssignedIdentity.outputs.principalId

@description('Client (application) ID, used by application code (e.g. DefaultAzureCredential, Kubernetes workload identity annotations).')
output clientId string = userAssignedIdentity.outputs.clientId
