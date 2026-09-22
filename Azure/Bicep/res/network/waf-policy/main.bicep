metadata name = 'Web Application Firewall policy'
metadata description = 'WAF policy (OWASP managed rules plus custom rules) attached to an Application Gateway or Front Door (wraps AVM).'

import { roleAssignmentType } from '../../../utl/types/main.bicep'

@export()
@description('A custom WAF rule, evaluated before the managed OWASP rules.')
type customRuleType = {
  @description('Name of the rule.')
  name: string

  @description('Evaluation order relative to other custom rules. Lower runs first.')
  priority: int

  @description('Block, Allow, Log or AnomalyScoring.')
  action: 'Block' | 'Allow' | 'Log' | 'AnomalyScoring'

  @description('Match conditions. All must match (AND) for the rule to trigger. Each condition compares a request field (e.g. RequestUri, RemoteAddr, RequestHeaders) against matchValues.')
  matchConditions: {
    matchVariables: { variableName: string, selector: string? }[]
    operator: string
    negationConditon: bool?
    matchValues: string[]
    transforms: string[]?
  }[]
}

@description('Name of the WAF policy.')
param name string

@description('Azure region. Defaults to the resource group location.')
param location string = resourceGroup().location

@description('Tags applied to the policy.')
param tags object = {}

@description('Prevention blocks matching requests. Detection only logs them; use it to validate rules before switching to Prevention.')
@allowed([
  'Prevention'
  'Detection'
])
param mode string = 'Prevention'

@description('OWASP Core Rule Set version.')
@allowed([
  '3.1'
  '3.2'
])
param managedRuleSetVersion string = '3.2'

@description('Maximum request body size the WAF inspects, in KB.')
param maxRequestBodySizeInKb int = 128

@description('Maximum file upload size the WAF allows, in MB.')
param fileUploadLimitInMb int = 100

@description('Custom rules, evaluated before the managed rule set.')
param customRules customRuleType[] = []

@description('RBAC role assignments on the policy.')
param roleAssignments roleAssignmentType[] = []

module wafPolicy 'br/public:avm/res/network/application-gateway-web-application-firewall-policy:0.3.0' = {
  name: '${take(name, 40)}-avm'
  params: {
    name: name
    location: location
    tags: tags
    policySettings: {
      mode: mode
      state: 'Enabled'
      requestBodyCheck: true
      maxRequestBodySizeInKb: maxRequestBodySizeInKb
      fileUploadLimitInMb: fileUploadLimitInMb
    }
    managedRules: {
      managedRuleSets: [
        {
          ruleSetType: 'OWASP'
          ruleSetVersion: managedRuleSetVersion
        }
      ]
    }
    customRules: customRules
    roleAssignments: roleAssignments
  }
}

@description('Resource ID of the WAF policy. Pass this to the application-gateway or front-door module\'s firewallPolicyResourceId.')
output resourceId string = wafPolicy.outputs.resourceId

@description('Name of the WAF policy.')
output name string = wafPolicy.outputs.name
