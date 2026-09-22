# Documentation

Module-level docs stay next to their module (`Azure/Bicep/res/.../README.md`, `Azure/Terraform/res/.../README.md`), because GitHub renders a folder's `README.md` automatically when you browse into it, and that's also where the Terraform Registry and the AVM modules themselves expect documentation to live. A change to a module's `variables.tf` and a change to its docs then sit in the same folder, which is what keeps them from drifting apart.

Everything else — the tool overviews, conventions and agent rules that used to sit at the top of `Azure/Bicep/` and `Azure/Terraform/` — lives here instead, so those two folders hold only code and this is one place to start reading. Browsing straight into `Azure/Bicep/` or `Azure/Terraform/` on GitHub no longer shows an explanation; start from here or from the root [README](../README.md).

## Per cloud, per tool

| | Bicep | Terraform |
|---|---|---|
| Module catalog, usage, automation | [bicep/README.md](bicep/README.md) | [terraform/README.md](terraform/README.md) |
| Naming, parameter/variable shape, secure defaults | [bicep/conventions.md](bicep/conventions.md) | [terraform/conventions.md](terraform/conventions.md) |
| Rules for agents writing IaC here | [bicep/AGENTS.md](bicep/AGENTS.md) | [terraform/AGENTS.md](terraform/AGENTS.md) |

Both are Azure today ([Azure/Bicep](../Azure/Bicep), [Azure/Terraform](../Azure/Terraform)). AWS modules (CloudFormation and Terraform) are planned; when added they'll live at `AWS/CloudFormation` and `AWS/Terraform`, with `docs/aws/` alongside `docs/bicep/` and `docs/terraform/` above. Every module ID already carries the cloud (`azure:bicep:res/...`, eventually `aws:terraform:res/...`), defined by the one schema both clouds and tools share: [../schema/module.schema.json](../schema/module.schema.json).

## Cross-cutting

- [examples-workflow](examples-workflow/) — reference GitHub Actions workflows, one per tool, for a separate *environments* repository that consumes a pinned release of this one. Not runnable here; see its README for why.

## Individual modules

Each module's own `README.md`, sitting inside its `res/<provider>/<module>/` folder, documents its defaults, gotchas and a short usage snippet. The module tables in [bicep/README.md](bicep/README.md#modules) and [terraform/README.md](terraform/README.md#modules) link every one of them.
