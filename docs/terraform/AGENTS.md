# Rules for agents writing IaC with these modules

Read [conventions.md](conventions.md) first. The short version:

1. **Use the modules in `Azure/Terraform/res/` and `Azure/Terraform/ptn/` before writing raw resources.** Only fall back to a raw resource or an AVM module directly when nothing here fits, and say so.
2. **Read `module.json`, `variables.tf` and `outputs.tf` before using a module.** Use the exact variable names and types you find there. Do not guess variable names from AVM or from memory.
3. **Look at each module's `tests/`** for working usage before composing modules.
4. **Wire modules through outputs**, not hard-coded resource IDs. `virtual-network` returns `subnet_resource_ids` as a map keyed by the same keys as its `subnets` variable.
5. **Optional features are nullable objects**, not empty strings: `private_endpoint = { subnet_resource_id = ... }`, `diagnostics = { workspace_resource_id = ... }`, `registry = { ... }`. Set them to `null` (or omit them) to skip the feature.
6. **Collection keys must be static.** Write map keys and set members as literals. Never derive them from another resource's ID or attribute, which is unknown until apply.
7. **Keep the secure defaults.** Do not enable public network access, shared keys, local auth or FTP unless the user asked for it. If you do, add a comment explaining why.
8. **No secrets in variables, outputs or app settings.** Use managed identity and RBAC (`role_assignments`), or Key Vault references. Mark any secret variable `sensitive = true`.
9. **No environment-specific values in this repo**: no real subscription IDs, tenant IDs or names. Use placeholders such as `00000000-0000-0000-0000-000000000000`.
10. **Every new `variable` and `output` needs a `description`.** Every new module needs `module.json`, a README and `tests/defaults/main.tf`.
11. **Pin AVM to an exact version** and keep `wraps.version` in `module.json` in sync.
12. **Validate before you finish:** `python3 Azure/Terraform/scripts/validate.py` must pass. It does not plan or apply; do not claim a module is deployed because it validates.
