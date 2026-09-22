# Logic App (Consumption)

Consumption-tier Logic App workflow. Wraps `br/public:avm/res/logic/workflow:0.6.0`.

## Scope

**Consumption tier only.** This is the classic, designer-based, pay-per-execution Logic App — one workflow per resource, billed per action execution. It is not the **Standard** tier (App Service-hosted, stateful, VNet-integrated, multiple workflows per app), which this module does not cover; that tier is closer in shape to a Function App than to this resource.

## Triggers and actions are free-form

`triggers` and `actions` are passed straight through as Workflow Definition Language JSON — there is no fixed schema to expose as Bicep types, because Logic Apps' definition language is itself open-ended (any connector, any shape). Design the workflow in the Azure portal designer first, then copy its trigger and action JSON into these parameters; that is the normal workflow for treating a Logic App as code.

## Identity, not connection secrets

Grant the workflow's system-assigned identity access to the resources it calls (Key Vault, Storage, Service Bus, or an HTTP endpoint you own) through *those* resources' `roleAssignments`, using this module's `systemAssignedMIPrincipalId` output. Connectors that support Entra ID authentication (Azure Blob, Key Vault, HTTP with managed identity) then need no stored secret. Connectors to third-party SaaS still need their own connection, created separately (usually through the portal, since API connections have their own OAuth flow outside what Bicep manages well).

## Usage

```bicep
module workflow '../../res/logic/workflow/main.bicep' = {
  name: 'workflow'
  params: {
    name: 'logic-order-approval'
    triggers: {
      manual: {
        type: 'Request'
        kind: 'Http'
        inputs: { schema: {} }
      }
    }
    actions: {
      Response: {
        type: 'Response'
        kind: 'Http'
        inputs: { statusCode: 200, body: 'OK' }
      }
    }
  }
}
```

## Tests

- [tests/defaults](tests/defaults/main.test.bicep): HTTP trigger with a response action
