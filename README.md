# Modules

Opinionated, secure-by-default infrastructure-as-code modules that wrap each cloud's own verified-module ecosystem — [Azure Verified Modules](https://azure.github.io/Azure-Verified-Modules/) today, more later. Grouped by cloud first, then by tool, since a tool like Terraform can span clouds but a module never should:

```
Azure/
├── Bicep/          Bicep modules (Azure-only by definition)
└── Terraform/       Terraform modules targeting Azure
AWS/                  planned: CloudFormation/ and Terraform/ targeting AWS
```

| Folder | Contains |
|---|---|
| [Azure/Bicep](Azure/Bicep) | Bicep module code only — docs at [docs/bicep](docs/bicep) |
| [Azure/Terraform](Azure/Terraform) | Terraform module code (targeting Azure) only — docs at [docs/terraform](docs/terraform) |
| [docs](docs) | Tool overviews, conventions, agent rules and the examples-workflow example |
| [schema](schema) | The one `module.json` shape every module, cloud and tool shares |

37 Bicep modules and 35 Terraform modules exist at matching paths (`Azure/Bicep/res/storage/storage-account` ↔ `Azure/Terraform/res/storage/storage-account`), with the same secure defaults and the same intent metadata, so the two can be compared side by side. The Bicep count is two higher: Virtual WAN Hub has no published AVM Terraform module (an upstream gap, documented in [docs/terraform/README.md](docs/terraform/README.md)), and Azure Functions is a separate Bicep module (`res/web/function-app`) where the Terraform side folds it into `res/web/app-service`.

Secure defaults everywhere: private networking, Entra ID only authentication, TLS 1.2, diagnostics. Every module has metadata (`module.json`) describing when to use it, and tests that double as examples, so the repo can also be read by agents.

## Status

The modules build, lint and validate in CI. They have not been deployed to Azure, so treat them as `preview`.

## Nothing here deploys to Azure

This repository is a public module library. Deployments belong in a separate private repository that pins a release of these modules; [docs/examples-workflow](docs/examples-workflow) shows the pattern for both Bicep and Terraform.

## Releases

Each tool within each cloud is versioned independently with its own tag: `azure-bicep/vX.Y.Z` and `azure-terraform/vX.Y.Z` today (an `aws-` prefix joins them later). Pin to a tag or commit SHA, never a branch.

## License

[MIT](LICENSE)
