# Azure AI Foundry

Foundry resource (`AIServices` account) with model deployments, projects and private networking. Wraps `Azure/avm-res-cognitiveservices-account/azurerm` 0.11.1. Projects are created with an `azapi_resource` of type `Microsoft.CognitiveServices/accounts/projects`, because the upstream module does not create them.

## Defaults

- Public network access **disabled**, firewall default action `Deny`
- API keys **disabled** (`local_auth_enabled = false`): callers use Entra ID, for example with the `Cognitive Services OpenAI User` role
- System-assigned managed identity, and project management enabled
- Custom subdomain set to the resource name (required for Entra ID and private endpoints)

## Private networking

Pass `private_endpoint` with all three private DNS zones: `privatelink.cognitiveservices.azure.com`, `privatelink.openai.azure.com` and `privatelink.services.ai.azure.com`.

## Scope

This module covers the Foundry resource and its projects. The full agent "standard setup" with bring-your-own Cosmos DB, AI Search and Storage is a pattern, not covered here.

Model availability, versions and quota vary by region and subscription. Check them before deploying `model_deployments`.

## Usage

```hcl
module "foundry" {
  source = "../../res/cognitive-services/foundry"

  name              = "aif-example-001"
  location          = "swedencentral"
  resource_group_id = azurerm_resource_group.this.id

  projects = {
    "proj-example" = { display_name = "Example project" }
  }

  model_deployments = {
    "gpt-4o" = {
      model = { format = "OpenAI", name = "gpt-4o", version = "2024-11-20" }
      sku   = { name = "GlobalStandard", capacity = 10 }
    }
  }
}
```

## Tests

- [tests/defaults](tests/defaults/main.tf): one model deployment and one project
