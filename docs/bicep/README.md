# Bicep modules

Opinionated, secure-by-default Bicep modules that wrap [Azure Verified Modules (AVM)](https://azure.github.io/Azure-Verified-Modules/). Each module pins an exact AVM version from the Microsoft Container Registry and adds this repo's defaults: private networking, Entra ID only authentication, TLS 1.2, diagnostics and consistent parameter names.

The modules are also designed to be read by agents: every parameter and output has a description, every module has a `module.json` describing when to use it, and every module has tests that double as examples.

This page, [conventions.md](conventions.md) and [AGENTS.md](AGENTS.md) used to live inside `Azure/Bicep/`; they moved here so that folder holds only code. Module-level docs did **not** move — each module keeps its own `README.md` next to its `main.bicep`, since GitHub renders that automatically when you browse the folder.

## Layout

```
Azure/Bicep/
├── res/<provider>/<module>/     Single-resource modules
│   ├── main.bicep
│   ├── module.json              Metadata for humans, catalogs and agents
│   ├── README.md
│   └── tests/<case>/main.test.bicep
├── ptn/                         Pattern modules that compose res modules (none yet)
├── utl/types/                   Shared exported types
├── scripts/validate.py          Build, lint and metadata checks (also run in CI)
└── bicepconfig.json             Linter rules
```

The `module.json` shape is defined by the shared schema at [../../schema/module.schema.json](../../schema/module.schema.json).

## Modules

| Area | Module | Wraps AVM | Purpose |
|---|---|---|---|
| Identity | [res/managed-identity/user-assigned-identity](../../Azure/Bicep/res/managed-identity/user-assigned-identity) | `managed-identity/user-assigned-identity` 0.6.0 | Standalone identity, federated for AKS/GitHub OIDC |
| Networking | [res/network/virtual-network](../../Azure/Bicep/res/network/virtual-network) | `network/virtual-network` 0.10.2 | VNet with typed subnets and peerings |
| | [res/network/network-security-group](../../Azure/Bicep/res/network/network-security-group) | `network/network-security-group` 0.5.3 | NSG with typed rules and explicit deny-all |
| | [res/network/private-endpoint](../../Azure/Bicep/res/network/private-endpoint) | `network/private-endpoint` 0.12.1 | Private endpoint with DNS zone group |
| | [res/network/private-dns-zone](../../Azure/Bicep/res/network/private-dns-zone) | `network/private-dns-zone` 0.8.1 | Private DNS zone linked to VNets |
| | [res/network/route-table](../../Azure/Bicep/res/network/route-table) | `network/route-table` 0.5.0 | User-defined routes |
| | [res/network/load-balancer](../../Azure/Bicep/res/network/load-balancer) | `network/load-balancer` 0.8.0 | Internal load balancer |
| | [res/network/application-gateway](../../Azure/Bicep/res/network/application-gateway) | `network/application-gateway` 0.10.0 | Layer 7 load balancer with WAF |
| | [res/network/waf-policy](../../Azure/Bicep/res/network/waf-policy) | `network/application-gateway-web-application-firewall-policy` 0.3.0 | WAF policy for Application Gateway |
| | [res/network/azure-firewall](../../Azure/Bicep/res/network/azure-firewall) | `network/azure-firewall` 0.11.1 | Managed hub firewall |
| | [res/network/firewall-policy](../../Azure/Bicep/res/network/firewall-policy) | `network/firewall-policy` 0.3.6 | Rules for Azure Firewall |
| | [res/network/virtual-wan-hub](../../Azure/Bicep/res/network/virtual-wan-hub) | `network/virtual-wan` 0.4.3 + `network/virtual-hub` 0.5.1 | Managed hub-and-spoke (Virtual WAN) |
| | [res/cdn/profile](../../Azure/Bicep/res/cdn/profile) | `cdn/profile` 0.20.0 | Front Door: global entry point and CDN |
| Monitoring | [res/operational-insights/log-analytics-workspace](../../Azure/Bicep/res/operational-insights/log-analytics-workspace) | `operational-insights/workspace` 0.16.1 | Destination for diagnostics |
| | [res/insights/component](../../Azure/Bicep/res/insights/component) | `insights/component` 0.8.0 | Application Insights (APM) |
| Security | [res/key-vault/key-vault](../../Azure/Bicep/res/key-vault/key-vault) | `key-vault/vault` 0.14.2 | RBAC, purge-protected, private vault |
| Data | [res/storage/storage-account](../../Azure/Bicep/res/storage/storage-account) | `storage/storage-account` 0.33.1 | Private, Entra ID only storage with containers |
| | [res/cosmos-db/account](../../Azure/Bicep/res/cosmos-db/account) | `document-db/database-account` 0.21.1 | Cosmos DB account, Entra ID only, private by default |
| | [res/sql/server](../../Azure/Bicep/res/sql/server) | `sql/server` 0.22.1 | Azure SQL logical server and databases |
| | [res/sql/managed-instance](../../Azure/Bicep/res/sql/managed-instance) | `sql/managed-instance` 0.5.0 | SQL Managed Instance, Entra ID only |
| | [res/cache/redis](../../Azure/Bicep/res/cache/redis) | `cache/redis` 0.18.0 | Redis Cache, Entra ID only |
| Messaging | [res/service-bus/namespace](../../Azure/Bicep/res/service-bus/namespace) | `service-bus/namespace` 0.17.1 | Queues, topics and subscriptions |
| | [res/event-hub/namespace](../../Azure/Bicep/res/event-hub/namespace) | `event-hub/namespace` 0.15.1 | Event streaming |
| Integration | [res/logic/workflow](../../Azure/Bicep/res/logic/workflow) | `logic/workflow` 0.6.0 | Consumption-tier Logic App |
| | [res/api-management/service](../../Azure/Bicep/res/api-management/service) | `api-management/service` 0.14.4 | API gateway |
| AI | [res/cognitive-services/foundry](../../Azure/Bicep/res/cognitive-services/foundry) | `cognitive-services/account` 0.19.1 | Azure AI Foundry with model deployments and projects |
| | [res/search/search-service](../../Azure/Bicep/res/search/search-service) | `search/search-service` 0.13.0 | AI Search for vector and hybrid retrieval |
| Compute | [res/compute/virtual-machine](../../Azure/Bicep/res/compute/virtual-machine) | `compute/virtual-machine` 0.22.3 | Linux or Windows VM, no public IP |
| | [res/container-instance/container-group](../../Azure/Bicep/res/container-instance/container-group) | `container-instance/container-group` 0.7.1 | Container without an orchestrator |
| | [res/container-service/managed-cluster](../../Azure/Bicep/res/container-service/managed-cluster) | `container-service/managed-cluster` 0.14.0 | AKS |
| | [res/web/app-service-plan](../../Azure/Bicep/res/web/app-service-plan) | `web/serverfarm` 0.7.0 | App Service plan |
| | [res/web/app-service](../../Azure/Bicep/res/web/app-service) | `web/site` 0.24.0 | Web app or function app |
| | [res/web/function-app](../../Azure/Bicep/res/web/function-app) | `web/site` 0.24.0 | Azure Functions, keyless storage |
| | [res/web/static-site](../../Azure/Bicep/res/web/static-site) | `web/static-site` 0.9.6 | Static Web App |
| | [res/container-registry/registry](../../Azure/Bicep/res/container-registry/registry) | `container-registry/registry` 0.13.1 | Private container registry |
| | [res/app/managed-environment](../../Azure/Bicep/res/app/managed-environment) | `app/managed-environment` 0.16.0 | Container Apps environment |
| | [res/app/container-app](../../Azure/Bicep/res/app/container-app) | `app/container-app` 0.23.0 | Container app |

Each module's own README has a usage snippet; [conventions.md](conventions.md) covers how to wire several together (naming, shared parameters, secure defaults).

## Use a module

From a workflow, check the repo out at a pinned tag and reference the module by relative path. Bicep cannot reference a Git URL directly.

```yaml
- uses: actions/checkout@v4
  with:
    repository: <owner>/Modules
    ref: azure-bicep/v0.1.0  # pin to a tag or commit SHA, never a branch
    path: .modules
```

```bicep
module storage '../.modules/Azure/Bicep/res/storage/storage-account/main.bicep' = {
  name: 'storage'
  params: {
    name: 'stexample001'
    containerNames: ['data']
  }
}
```

## Validate locally

```bash
python3 Azure/Bicep/scripts/validate.py
```

Requires the [Bicep CLI](https://learn.microsoft.com/azure/azure-resource-manager/bicep/install).

## Automation

| Workflow | When | What |
|---|---|---|
| `bicep-validate` | Pull requests and pushes touching `Azure/Bicep/` | Builds, lints and checks metadata for every module |
| `secret-scan` | Pull requests, pushes and weekly | Scans the full history with gitleaks |
| `bicep-release` | Pushing an `azure-bicep/vX.Y.Z` tag | Validates, then publishes a GitHub release with a zip of `Azure/Bicep/` (pre-release while below 1.0) |
| Dependabot | Weekly | Updates the SHA-pinned GitHub Actions |
| Renovate | Continuous, needs the [Renovate GitHub app](https://github.com/apps/renovate) installed | Opens a pull request per AVM module bump, updating `main.bicep` and `module.json` together |

Nothing in this repository deploys to Azure. [../examples-workflow](../examples-workflow) shows how a separate private repository does that.

## Release

```bash
git tag azure-bicep/v0.1.0
git push origin azure-bicep/v0.1.0
```
