# Bicep modules

Opinionated, secure-by-default Bicep modules that wrap [Azure Verified Modules (AVM)](https://azure.github.io/Azure-Verified-Modules/). Each module pins an exact AVM version from the Microsoft Container Registry and adds this repo's defaults: private networking, Entra ID only authentication, TLS 1.2, diagnostics and consistent parameter names.

The modules are also designed to be read by agents: every parameter and output has a description, every module has a `module.json` describing when to use it, and every module has tests that double as examples.

## Layout

```
Bicep/
├── res/<provider>/<module>/     Single-resource modules
│   ├── main.bicep
│   ├── module.json              Metadata for humans, catalogs and agents
│   ├── README.md
│   └── tests/<case>/main.test.bicep
├── ptn/                         Pattern modules that compose res modules (none yet)
├── utl/types/                   Shared exported types
├── examples/                    Multi-module compositions
├── schema/module.schema.json    Shape of module.json
├── scripts/validate.py          Build, lint and metadata checks (also run in CI)
├── docs/conventions.md          Naming, parameters, secure defaults
├── AGENTS.md                    Rules for agents writing IaC in this repo
└── bicepconfig.json             Linter rules
```

## Modules

| Area | Module | Wraps AVM | Purpose |
|---|---|---|---|
| Networking | [res/network/virtual-network](res/network/virtual-network) | `network/virtual-network` 0.10.2 | VNet with typed subnets and peerings |
| | [res/network/network-security-group](res/network/network-security-group) | `network/network-security-group` 0.5.3 | NSG with typed rules and explicit deny-all |
| | [res/network/private-endpoint](res/network/private-endpoint) | `network/private-endpoint` 0.12.1 | Private endpoint with DNS zone group |
| | [res/network/private-dns-zone](res/network/private-dns-zone) | `network/private-dns-zone` 0.8.1 | Private DNS zone linked to VNets |
| Monitoring | [res/operational-insights/log-analytics-workspace](res/operational-insights/log-analytics-workspace) | `operational-insights/workspace` 0.16.1 | Destination for diagnostics |
| Security | [res/key-vault/key-vault](res/key-vault/key-vault) | `key-vault/vault` 0.14.2 | RBAC, purge-protected, private vault |
| Data | [res/storage/storage-account](res/storage/storage-account) | `storage/storage-account` 0.33.1 | Private, Entra ID only storage with containers |
| | [res/sql/managed-instance](res/sql/managed-instance) | `sql/managed-instance` 0.5.0 | SQL Managed Instance, Entra ID only |
| Messaging | [res/service-bus/namespace](res/service-bus/namespace) | `service-bus/namespace` 0.17.1 | Queues, topics and subscriptions |
| | [res/event-hub/namespace](res/event-hub/namespace) | `event-hub/namespace` 0.15.1 | Event streaming |
| AI | [res/cognitive-services/foundry](res/cognitive-services/foundry) | `cognitive-services/account` 0.19.1 | Azure AI Foundry with model deployments and projects |
| | [res/search/search-service](res/search/search-service) | `search/search-service` 0.13.0 | AI Search for vector and hybrid retrieval |
| Compute | [res/compute/virtual-machine](res/compute/virtual-machine) | `compute/virtual-machine` 0.22.3 | Linux or Windows VM, no public IP |
| | [res/web/app-service-plan](res/web/app-service-plan) | `web/serverfarm` 0.7.0 | App Service plan |
| | [res/web/app-service](res/web/app-service) | `web/site` 0.24.0 | Web app or function app |
| | [res/container-registry/registry](res/container-registry/registry) | `container-registry/registry` 0.13.1 | Private container registry |
| | [res/app/managed-environment](res/app/managed-environment) | `app/managed-environment` 0.16.0 | Container Apps environment |
| | [res/app/container-app](res/app/container-app) | `app/container-app` 0.23.0 | Container app |

See [examples/private-web-app](examples/private-web-app) for the networking, App Service, Storage and Foundry modules wired together.

## Use a module

From a workflow, check the repo out at a pinned tag and reference the module by relative path. Bicep cannot reference a Git URL directly.

```yaml
- uses: actions/checkout@v4
  with:
    repository: <owner>/Modules
    ref: bicep/v0.1.0        # pin to a tag or commit SHA, never a branch
    path: .modules
```

```bicep
module storage '../.modules/Bicep/res/storage/storage-account/main.bicep' = {
  name: 'storage'
  params: {
    name: 'stexample001'
    containerNames: ['data']
  }
}
```

## Validate locally

```bash
python3 scripts/validate.py
```

Requires the [Bicep CLI](https://learn.microsoft.com/azure/azure-resource-manager/bicep/install).

## Automation

| Workflow | When | What |
|---|---|---|
| `bicep-validate` | Pull requests and pushes touching `Bicep/` | Builds, lints and checks metadata for every module |
| `secret-scan` | Pull requests, pushes and weekly | Scans the full history with gitleaks |
| `bicep-release` | Pushing a `bicep/vX.Y.Z` tag | Validates, then publishes a GitHub release with a zip of `Bicep/` (pre-release while below 1.0) |
| Dependabot | Weekly | Updates the SHA-pinned GitHub Actions |
| Renovate | Continuous, needs the [Renovate GitHub app](https://github.com/apps/renovate) installed | Opens a pull request per AVM module bump, updating `main.bicep` and `module.json` together |

Nothing in this repository deploys to Azure. [examples/deploy-workflow](examples/deploy-workflow) shows how a separate private repository does that.

## Release

```bash
git tag bicep/v0.1.0
git push origin bicep/v0.1.0
```
