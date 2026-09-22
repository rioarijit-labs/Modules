# Logic App (Consumption)

Consumption-tier Logic App workflow. Wraps `Azure/avm-res-logic-workflow/azurerm` 0.1.2.

## Scope

**Consumption tier only.** This is the classic, designer-based, pay-per-execution Logic App — one workflow per resource, billed per action execution. It is not the **Standard** tier (App Service-hosted, stateful, VNet-integrated, multiple workflows per app), which this module does not cover.

## Triggers and actions are free-form

`triggers` and `actions` are merged with `workflow_parameters` into a single Workflow Definition Language document and passed straight through — there is no fixed schema to expose as Terraform types, because Logic Apps' definition language is itself open-ended. Design the workflow in the Azure portal designer first, then copy its trigger and action JSON into these variables.

## Identity, not connection secrets

Grant the workflow's system-assigned identity access to the resources it calls through *those* resources' `role_assignments`, using this module's `system_assigned_mi_principal_id` output. Connectors that support Entra ID authentication then need no stored secret.

## Usage

```hcl
module "workflow" {
  source = "../../res/logic/workflow"

  name              = "logic-order-approval"
  location          = "westeurope"
  resource_group_id = azurerm_resource_group.this.id

  triggers = {
    manual = {
      type = "Request"
      kind = "Http"
      inputs = { schema = {} }
    }
  }

  actions = {
    Response = {
      type   = "Response"
      kind   = "Http"
      inputs = { statusCode = 200, body = "OK" }
    }
  }
}
```

## Tests

- [tests/defaults](tests/defaults/main.tf): HTTP trigger with a response action
