# Terraform modules

Opinionated, secure-by-default Terraform modules that wrap [Azure Verified Modules (AVM)](https://azure.github.io/Azure-Verified-Modules/). Each module pins an exact AVM version from the Terraform Registry and adds this repo's defaults: private networking, Entra ID only authentication, TLS 1.2, diagnostics and consistent variable names.

These are the same modules as in [../../Azure/Bicep](../../Azure/Bicep), with the same folder paths, the same secure defaults and the same intent metadata, so the two can be compared side by side. They are also designed to be read by agents: every variable and output has a description, every module has a `module.json` describing when to use it, and every module has tests that double as examples.

This page, [conventions.md](conventions.md) and [AGENTS.md](AGENTS.md) used to live inside `Azure/Terraform/`; they moved here so that folder holds only code. Module-level docs did **not** move — each module keeps its own `README.md` next to its `main.tf`, since GitHub renders that automatically when you browse the folder.

## Layout

```
Azure/Terraform/
├── res/<provider>/<module>/     Single-resource modules
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── versions.tf
│   ├── module.json              Metadata for humans, catalogs and agents
│   ├── README.md
│   └── tests/<case>/main.tf
├── ptn/                         Pattern modules that compose res modules (none yet)
└── scripts/validate.py          fmt, init, validate and metadata checks (also run in CI)
```

The `module.json` shape is defined by the shared schema at [../../schema/module.schema.json](../../schema/module.schema.json).

## Modules

| Area | Module | Wraps AVM | Purpose |
|---|---|---|---|
| Networking | [res/network/virtual-network](../../Azure/Terraform/res/network/virtual-network) | `avm-res-network-virtualnetwork` 0.22.2 | VNet with typed subnets and peerings |
| | [res/network/network-security-group](../../Azure/Terraform/res/network/network-security-group) | `avm-res-network-networksecuritygroup` 0.5.1 | NSG with typed rules and explicit deny-all |
| | [res/network/private-endpoint](../../Azure/Terraform/res/network/private-endpoint) | `avm-res-network-privateendpoint` 0.2.0 | Private endpoint with DNS zone group |
| | [res/network/private-dns-zone](../../Azure/Terraform/res/network/private-dns-zone) | `avm-res-network-privatednszone` 0.5.0 | Private DNS zone linked to VNets |
| | [res/network/route-table](../../Azure/Terraform/res/network/route-table) | `avm-res-network-routetable` 0.5.0 | UDR route table |
| | [res/network/load-balancer](../../Azure/Terraform/res/network/load-balancer) | `avm-res-network-loadbalancer` 0.5.0 | Internal load balancer |
| | [res/network/application-gateway](../../Azure/Terraform/res/network/application-gateway) | `avm-res-network-applicationgateway` 0.5.3 | HTTP(S) application gateway |
| | [res/network/waf-policy](../../Azure/Terraform/res/network/waf-policy) | `avm-res-network-applicationgatewaywebapplicationfirewallpolicy` 0.2.0 | WAF policy for Application Gateway |
| | [res/network/azure-firewall](../../Azure/Terraform/res/network/azure-firewall) | `avm-res-network-azurefirewall` 0.4.0 | Azure Firewall |
| | [res/network/firewall-policy](../../Azure/Terraform/res/network/firewall-policy) | `avm-res-network-firewallpolicy` 0.3.4 | Firewall policy with rule collection groups |
| Monitoring | [res/operational-insights/log-analytics-workspace](../../Azure/Terraform/res/operational-insights/log-analytics-workspace) | `avm-res-operationalinsights-workspace` 0.5.1 | Destination for diagnostics |
| | [res/insights/component](../../Azure/Terraform/res/insights/component) | `avm-res-insights-component` 0.4.0 | Application Insights (workspace-based) |
| Identity | [res/managed-identity/user-assigned-identity](../../Azure/Terraform/res/managed-identity/user-assigned-identity) | `avm-res-managedidentity-userassignedidentity` 0.5.2 | User-assigned managed identity with federated credentials |
| Security | [res/key-vault/key-vault](../../Azure/Terraform/res/key-vault/key-vault) | `avm-res-keyvault-vault` 0.11.0 | RBAC, purge-protected, private vault |
| Data | [res/storage/storage-account](../../Azure/Terraform/res/storage/storage-account) | `avm-res-storage-storageaccount` 0.10.0 | Private, Entra ID only storage with containers |
| | [res/cosmos-db/account](../../Azure/Terraform/res/cosmos-db/account) | `avm-res-documentdb-databaseaccount` 0.11.0 | Cosmos DB account, Entra ID only, private by default |
| | [res/sql/server](../../Azure/Terraform/res/sql/server) | `avm-res-sql-server` 0.2.1 | Azure SQL logical server with one or more databases |
| | [res/sql/managed-instance](../../Azure/Terraform/res/sql/managed-instance) | `avm-res-sql-managedinstance` 0.3.1 | SQL Managed Instance, Entra ID only |
| | [res/cache/redis](../../Azure/Terraform/res/cache/redis) | `avm-res-cache-redis` 0.4.0 | Managed Redis cache, Entra ID only |
| Messaging | [res/service-bus/namespace](../../Azure/Terraform/res/service-bus/namespace) | `avm-res-servicebus-namespace` 0.4.0 | Queues, topics and subscriptions |
| | [res/event-hub/namespace](../../Azure/Terraform/res/event-hub/namespace) | `avm-res-eventhub-namespace` 0.1.0 | Event streaming |
| | [res/logic/workflow](../../Azure/Terraform/res/logic/workflow) | `avm-res-logic-workflow` 0.1.2 | Logic App (Consumption) |
| AI | [res/cognitive-services/foundry](../../Azure/Terraform/res/cognitive-services/foundry) | `avm-res-cognitiveservices-account` 0.11.1 | Azure AI Foundry with model deployments and projects |
| | [res/search/search-service](../../Azure/Terraform/res/search/search-service) | `avm-res-search-searchservice` 0.3.0 | AI Search for vector and hybrid retrieval |
| Compute | [res/compute/virtual-machine](../../Azure/Terraform/res/compute/virtual-machine) | `avm-res-compute-virtualmachine` 0.21.0 | Linux or Windows VM, no public IP |
| | [res/container-instance/container-group](../../Azure/Terraform/res/container-instance/container-group) | `avm-res-containerinstance-containergroup` 0.2.0 | Single container group |
| | [res/container-service/managed-cluster](../../Azure/Terraform/res/container-service/managed-cluster) | `avm-res-containerservice-managedcluster` 0.8.3 | AKS, private API server, Entra ID RBAC only |
| | [res/web/app-service-plan](../../Azure/Terraform/res/web/app-service-plan) | `avm-res-web-serverfarm` 2.0.8 | App Service plan |
| | [res/web/app-service](../../Azure/Terraform/res/web/app-service) | `avm-res-web-site` 0.23.0 | Web app or function app |
| | [res/web/static-site](../../Azure/Terraform/res/web/static-site) | `avm-res-web-staticsite` 0.6.2 | Static Web App |
| | [res/container-registry/registry](../../Azure/Terraform/res/container-registry/registry) | `avm-res-containerregistry-registry` 0.8.0 | Private container registry |
| | [res/app/managed-environment](../../Azure/Terraform/res/app/managed-environment) | `avm-res-app-managedenvironment` 0.5.0 | Container Apps environment |
| | [res/app/container-app](../../Azure/Terraform/res/app/container-app) | `avm-res-app-containerapp` 0.9.0 | Container app |
| Integration | [res/api-management/service](../../Azure/Terraform/res/api-management/service) | `avm-res-apimanagement-service` 0.9.0 | API gateway |
| Networking (global) | [res/cdn/profile](../../Azure/Terraform/res/cdn/profile) | `avm-res-cdn-profile` 0.1.9 | Front Door: global entry point with CDN and failover |

## Use a module

Terraform can read a subdirectory of a Git repository directly. Pin to a release tag or commit SHA, never a branch.

```hcl
module "storage" {
  source = "git::https://github.com/<owner>/Modules.git//Azure/Terraform/res/storage/storage-account?ref=azure-terraform/v0.1.0"

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

The two sets share paths, defaults and metadata, but Terraform is not Bicep, so a few things differ. [conventions.md](conventions.md) explains why.

- **Location and resource group** are explicit inputs: `location` and `resource_group_id` (for example `azurerm_resource_group.this.id`).
- **Optional features are nullable objects**, for example `private_endpoint = { subnet_resource_id = ... }` and `diagnostics = { workspace_resource_id = ... }`, instead of empty-string flags. Terraform must know at plan time whether a resource exists, and a subnet or workspace created in the same apply has an unknown ID.
- **Collections are maps keyed by a static name**, and outputs such as `subnet_resource_ids` are maps too, not ordered lists.
- Some upstream AVM Terraform modules expose less than their Bicep counterparts. Gaps are noted in each module's README (for example Event Hubs consumer groups).
- **Virtual WAN Hub has no Terraform module here.** The Bicep side has `res/network/virtual-wan-hub`, composing `avm/res/network/virtual-wan` and `avm/res/network/virtual-hub`. Neither has a published AVM Terraform module (`Azure/avm-res-network-virtualwan/azurerm` and `Azure/avm-res-network-virtualhub/azurerm` both 404 on the registry as of this writing) — an upstream gap, not an oversight. Use native `azurerm_virtual_wan`/`azurerm_virtual_hub` resources if you need this in Terraform today.
- **SQL Database and Azure Functions are not separate modules.** `res/sql/server` accepts a `databases` map (so "SQL Server" and "SQL DB" are one module, same as Bicep), and `res/web/app-service` deploys either a web app or a function app depending on its `kind`/`os_type` inputs (that module predates this batch).

## Validate locally

```bash
python3 Azure/Terraform/scripts/validate.py                             # everything
python3 Azure/Terraform/scripts/validate.py res/web/app-service         # one module
```

Requires Terraform 1.11 or newer and network access to the Terraform Registry. `terraform validate` checks argument names, types and variable validation rules. It does not run a plan, so nothing here has been planned or applied against Azure.

## Automation

| Workflow | When | What |
|---|---|---|
| `terraform-validate` | Pull requests and pushes touching `Azure/Terraform/` | `terraform fmt`, `init` and `validate` for every test case, plus metadata checks |
| `terraform-release` | Pushing an `azure-terraform/vX.Y.Z` tag | Validates, then publishes a GitHub release with a zip of `Azure/Terraform/` (pre-release while below 1.0) |
| Renovate | Continuous, needs the Renovate GitHub app | One pull request per AVM module bump, updating `main.tf` and `module.json` together |

Nothing in this repository deploys to Azure. [../examples-workflow](../examples-workflow) shows how a separate private repository does that.

## Release

```bash
git tag azure-terraform/v0.1.0
git push origin azure-terraform/v0.1.0
```
