# Azure AI Foundry

Foundry resource (`AIServices` account) with model deployments, projects and private networking. Wraps `br/public:avm/res/cognitive-services/account:0.19.1`. Projects are created with the `Microsoft.CognitiveServices/accounts/projects` resource.

## Defaults

- Public network access **disabled**, firewall default action `Deny`
- API keys **disabled** (`disableLocalAuth`): callers use Entra ID, for example with the `Cognitive Services OpenAI User` role
- System-assigned managed identity, and project management enabled
- Custom subdomain set to the resource name (required for Entra ID and private endpoints)

## Private networking

Pass `privateEndpointSubnetResourceId` and all three private DNS zones: `privatelink.cognitiveservices.azure.com`, `privatelink.openai.azure.com` and `privatelink.services.ai.azure.com`.

## Scope

This module covers the Foundry resource and its projects. The full agent "standard setup" with bring-your-own Cosmos DB, AI Search and Storage is a pattern; see the AVM module `avm/ptn/ai-ml/ai-foundry`.

Model availability, versions and quota vary by region and subscription. Check them before deploying `modelDeployments`.

## Usage

```bicep
module foundry '../../res/cognitive-services/foundry/main.bicep' = {
  name: 'foundry'
  params: {
    name: 'aif-example-001'
    projects: [
      { name: 'proj-example', displayName: 'Example project' }
    ]
    modelDeployments: [
      {
        name: 'gpt-4o'
        model: { format: 'OpenAI', name: 'gpt-4o', version: '2024-11-20' }
        sku: { name: 'GlobalStandard', capacity: 10 }
      }
    ]
  }
}
```

## Tests

- [tests/defaults](tests/defaults/main.test.bicep): one model deployment and one project
