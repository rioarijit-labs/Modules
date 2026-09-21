# Deployment workflow example

[deploy.yml](deploy.yml) shows how a **separate, private environments repository** deploys with these modules. It is deliberately not in `.github/workflows`, so it never runs in this repository.

Why deployments do not live here: this repository is a public module library. A workflow that can reach an Azure subscription is an attack surface, and deployments belong with the environment that consumes the modules.

## The pattern

1. **Pin the modules.** The environments repo checks out this repository at a release tag (`bicep/v0.1.0`) or commit SHA, never a branch, and references modules by relative path.
2. **No secrets.** `azure/login` signs in with OIDC. The Entra app registration has a federated credential per GitHub environment and no client secret.
3. **What-if first.** Every run shows what would change before anything changes.
4. **Human approval to deploy.** The deploy job runs in an environment with required reviewers.
5. **Least privilege.** Reader for what-if, Contributor for deploy, scoped to a single resource group.
6. **Manual trigger only.** `workflow_dispatch`, never `pull_request`, so a forked pull request cannot start a deployment.

## Setting it up

See the header of [deploy.yml](deploy.yml) for the environments, variables and federated credentials it expects.
