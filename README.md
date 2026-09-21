# Modules

Opinionated, secure-by-default infrastructure-as-code modules for Azure that wrap [Azure Verified Modules (AVM)](https://azure.github.io/Azure-Verified-Modules/). The same 18 modules exist in two flavors, with the same folder paths, defaults and metadata:

| Folder | Tool | Docs |
|---|---|---|
| [Bicep](Bicep) | Bicep | [README](Bicep/README.md), [conventions](Bicep/docs/conventions.md) |
| [Terraform](Terraform) | Terraform | [README](Terraform/README.md), [conventions](Terraform/docs/conventions.md) |

Secure defaults everywhere: private networking, Entra ID only authentication, TLS 1.2, diagnostics. Every module has metadata (`module.json`) describing when to use it, and tests that double as examples, so the repo can also be read by agents.

## Status

The modules build, lint and validate in CI. They have not been deployed to Azure, so treat them as `preview`.

## Nothing here deploys to Azure

This repository is a public module library. Deployments belong in a separate private repository that pins a release of these modules; [Bicep/examples/deploy-workflow](Bicep/examples/deploy-workflow) shows the pattern.

## Releases

Each folder is versioned independently with its own tag: `bicep/vX.Y.Z` and `terraform/vX.Y.Z`. Pin to a tag or commit SHA, never a branch.

## License

[MIT](LICENSE)
