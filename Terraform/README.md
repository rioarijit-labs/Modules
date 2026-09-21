# Terraform modules

Opinionated, secure-by-default Terraform modules that wrap [Azure Verified Modules (AVM)](https://azure.github.io/Azure-Verified-Modules/). Each module pins an exact AVM version from the Terraform Registry and adds this repo's defaults: private networking, Entra ID only authentication, TLS 1.2, diagnostics and consistent variable names.

These are the same modules as in [../Bicep](../Bicep), with the same folder paths, the same secure defaults and the same intent metadata, so the two can be compared side by side. They are also designed to be read by agents: every variable and output has a description, every module has a `module.json` describing when to use it, and every module has tests that double as examples.

## Layout

```
Terraform/
├── res/<provider>/<module>/     Single-resource modules
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── versions.tf
│   ├── module.json              Metadata for humans, catalogs and agents
│   ├── README.md
│   └── tests/<case>/main.tf
├── ptn/                         Pattern modules that compose res modules (none yet)
├── docs/conventions.md          Naming, variables, secure defaults
├── AGENTS.md                    Rules for agents writing IaC in this repo
└── scripts/validate.py          fmt, init, validate and metadata checks (also run in CI)
```

The `module.json` shape is defined by [../Bicep/schema/module.schema.json](../Bicep/schema/module.schema.json), shared by both tools.

## Modules

| Area | Module | Wraps AVM | Purpose |
|---|---|---|---|
| Networking | [res/network/virtual-network](res/network/virtual-network) | `avm-res-network-virtualnetwork` 0.22.2 | VNet with typed subnets and peerings |
| | [res/network/network-security-group](res/network/network-security-group) | `avm-res-network-networksecuritygroup` 0.5.1 | NSG with typed rules and explicit deny-all |
| | [res/network/private-endpoint](res/network/private-endpoint) | `avm-res-network-privateendpoint` 0.2.0 | Private endpoint with DNS zone group |
| | [res/network/private-dns-zone](res/network/private-dns-zone) | `avm-res-network-privatednszone` 0.5.0 | Private DNS zone linked to VNets |
| Monitoring | [res/operational-insights/log-analytics-workspace](res/operational-insights/log-analytics-workspace) | `avm-res-operationalinsights-workspace` 0.5.1 | Destination for diagnostics |
| Security | [res/key-vault/key-vault](res/key-vault/key-vault) | `avm-res-keyvault-vault` 0.11.0 | RBAC, purge-protected, private vault |
| Data | [res/storage/storage-account](res/storage/storage-account) | `avm-res-storage-storageaccount` 0.10.0 | Private, Entra ID only storage with containers |
| | [res/sql/managed-instance](res/sql/managed-instance) | `avm-res-sql-managedinstance` 0.3.1 | SQL Managed Instance, Entra ID only |
| Messaging | [res/service-bus/namespace](res/service-bus/namespace) | `avm-res-servicebus-namespace` 0.4.0 | Queues, topics and subscriptions |
| | [res/event-hub/namespace](res/event-hub/namespace) | `avm-res-eventhub-namespace` 0.1.0 | Event streaming |
| AI | [res/cognitive-services/foundry](res/cognitive-services/foundry) | `avm-res-cognitiveservices-account` 0.11.1 | Azure AI Foundry with model deployments and projects |
| | [res/search/search-service](res/search/search-service) | `avm-res-search-searchservice` 0.3.0 | AI Search for vector and hybrid retrieval |
| Compute | [res/compute/virtual-machine](res/compute/virtual-machine) | `avm-res-compute-virtualmachine` 0.21.0 | Linux or Windows VM, no public IP |
| | [res/web/app-service-plan](res/web/app-service-plan) | `avm-res-web-serverfarm` 2.0.8 | App Service plan |
| | [res/web/app-service](res/web/app-service) | `avm-res-web-site` 0.23.0 | Web app or function app |
| | [res/container-registry/registry](res/container-registry/registry) | `avm-res-containerregistry-registry` 0.8.0 | Private container registry |
| | [res/app/managed-environment](res/app/managed-environment) | `avm-res-app-managedenvironment` 0.5.0 | Container Apps environment |
| | [res/app/container-app](res/app/container-app) | `avm-res-app-containerapp` 0.9.0 | Container app |

## Use a module

Terraform can read a subdirectory of a Git repository directly. Pin to a release tag or commit SHA, never a branch.

```hcl
module "storage" {
  source = "git::https://github.com/<owner>/Modules.git//Terraform/res/storage/storage-account?ref=terraform/v0.1.0"

  name              = "stexample001"
  location          = "westeurope"
  resource_group_id = azurerm_resource_group.this.id
  container_names   = ["data"]
}
```

Configure the providers in your root module. Most modules need `azapi`, and several need `azurerm` (each module's `versions.tf` lists what it uses):

```hcl
provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}
```

## Differences from the Bicep modules

The two sets share paths, defaults and metadata, but Terraform is not Bicep, so a few things differ. [docs/conventions.md](docs/conventions.md) explains why.

- **Location and resource group** are explicit inputs: `location` and `resource_group_id` (for example `azurerm_resource_group.this.id`).
- **Optional features are nullable objects**, for example `private_endpoint = { subnet_resource_id = ... }` and `diagnostics = { workspace_resource_id = ... }`, instead of empty-string flags. Terraform must know at plan time whether a resource exists, and a subnet or workspace created in the same apply has an unknown ID.
- **Collections are maps keyed by a static name**, and outputs such as `subnet_resource_ids` are maps too, not ordered lists.
- Some upstream AVM Terraform modules expose less than their Bicep counterparts. Gaps are noted in each module's README (for example Event Hubs consumer groups).

## Validate locally

```bash
python3 scripts/validate.py                       # everything
python3 scripts/validate.py res/web/app-service   # one module
```

Requires Terraform 1.11 or newer and network access to the Terraform Registry. `terraform validate` checks argument names, types and variable validation rules. It does not run a plan, so nothing here has been planned or applied against Azure.

## Automation

| Workflow | When | What |
|---|---|---|
| `terraform-validate` | Pull requests and pushes touching `Terraform/` | `terraform fmt`, `init` and `validate` for every test case, plus metadata checks |
| `terraform-release` | Pushing a `terraform/vX.Y.Z` tag | Validates, then publishes a GitHub release with a zip of `Terraform/` (pre-release while below 1.0) |
| Renovate | Continuous, needs the Renovate GitHub app | One pull request per AVM module bump, updating `main.tf` and `module.json` together |

## Release

```bash
git tag terraform/v0.1.0
git push origin terraform/v0.1.0
```
