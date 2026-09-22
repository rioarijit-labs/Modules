# Deployment workflow example

[bicep.yml](bicep.yml) and [terraform.yml](terraform.yml) show how a **separate, private environments repository** deploys with these modules. Both are deliberately kept outside `.github/workflows`, so neither ever runs in this repository.

Why deployments do not live here: this repository is a public module library. A workflow that can reach an Azure subscription is an attack surface, and deployments belong with the environment that consumes the modules.

## The pattern

1. **Pin the modules.**
   - Bicep can't reference a Git URL, so the environments repo checks this repository out at a release tag (`azure-bicep/v0.1.0`) or commit SHA, never a branch, and references modules by relative path.
   - Terraform reads a Git subdirectory directly, so the ref is pinned inline in `main.tf` (`?ref=azure-terraform/v0.1.0`) — no checkout step needed, and the pin shows up in that file's diff.
2. **No secrets.** `azure/login` signs in with OIDC. The Entra app registration has a federated credential per GitHub environment and no client secret.
3. **Preview first.** Bicep's `what-if` and Terraform's `plan` both show what would change before anything changes.
4. **Human approval to deploy.** The apply/deploy job runs in an environment with required reviewers.
5. **Least privilege.** Reader for the preview job, Contributor for apply, scoped to a single resource group.
6. **Manual trigger only.** `workflow_dispatch`, never `pull_request`, so a forked pull request cannot start a deployment.

## Terraform state

`terraform.yml` doesn't configure a backend, so it would use local state, which is wrong outside a demo: state would not persist between runs and could not be shared. Add a `backend.tf` in the environments repository (an `azurerm` backend pointing at a storage account is the usual choice) before using this for anything real.

## Setting it up

See the header comment of each workflow file for the environments, variables and federated credentials it expects.
