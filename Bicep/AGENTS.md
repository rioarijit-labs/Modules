# Rules for agents writing IaC with these modules

Read [docs/conventions.md](docs/conventions.md) first. The short version:

1. **Use the modules in `res/` and `ptn/` before writing raw resources.** Only fall back to a raw resource or an AVM module directly when nothing here fits, and say so.
2. **Read `module.json` and `main.bicep` before using a module.** Use the exact parameter names and types you find there. Do not guess parameter names from AVM or from memory.
3. **Look at `tests/` and `examples/`** for working usage before composing modules.
4. **Wire modules through outputs**, not hard-coded resource IDs. `virtual-network` returns `subnetResourceIds` in declaration order.
5. **Keep the secure defaults.** Do not enable public network access, shared keys, local auth or FTP unless the user asked for it. If you do, add a comment explaining why.
6. **No secrets in parameters, outputs or app settings.** Use managed identity and RBAC (`roleAssignments`), or Key Vault references.
7. **No environment-specific values in this repo**: no real subscription IDs, tenant IDs or names. Use placeholders such as `00000000-0000-0000-0000-000000000000`.
8. **Every new `param` and `output` needs `@description`.** Every new module needs `module.json`, a README and `tests/defaults/main.test.bicep`.
9. **Pin AVM to an exact version** and keep `wraps.version` in `module.json` in sync.
10. **Validate before you finish:** `python3 scripts/validate.py` must pass with no warnings.
