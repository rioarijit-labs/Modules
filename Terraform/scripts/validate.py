#!/usr/bin/env python3
"""Validate every Terraform module in this repo.

Checks:
  1. `terraform fmt -check -recursive` passes
  2. every test case initializes and validates (this also validates the wrapper module
     and the AVM module it calls)
  3. every variable and output has a description
  4. every module folder has a module.json that matches the required shape, an id that
     matches its folder path, and a pinned AVM version that matches main.tf

Usage:
  python3 scripts/validate.py                    validate everything
  python3 scripts/validate.py res/web/app-service   validate only the given module folders
  python3 scripts/validate.py --skip-init        skip terraform init/validate (fast checks only)

Requires the terraform CLI (1.11 or newer) and network access to the Terraform Registry.
"""
import json
import os
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
REQUIRED_KEYS = {"id", "tool", "name", "summary", "useWhen", "avoidWhen", "tags", "wraps", "maturity"}

errors: list[str] = []


def rel(path: Path) -> str:
    return str(path.relative_to(ROOT))


def run(args: list[str], cwd: Path) -> subprocess.CompletedProcess:
    env = {**os.environ, "TF_IN_AUTOMATION": "1", "TF_INPUT": "0"}
    return subprocess.run(args, cwd=cwd, capture_output=True, text=True, env=env)


def check_fmt() -> None:
    result = run(["terraform", "fmt", "-check", "-recursive", "-diff", "-no-color"], ROOT)
    if result.returncode != 0:
        errors.append("terraform fmt found unformatted files (run: terraform fmt -recursive):\n" + result.stdout.strip())


def check_test_case(test_dir: Path) -> None:
    init = run(["terraform", "init", "-backend=false", "-no-color", "-input=false"], test_dir)
    if init.returncode != 0:
        errors.append(f"{rel(test_dir)}: terraform init failed\n{init.stderr.strip()}")
        return
    validate = run(["terraform", "validate", "-no-color"], test_dir)
    if validate.returncode != 0:
        errors.append(f"{rel(test_dir)}: terraform validate failed\n{(validate.stdout + validate.stderr).strip()}")


def check_descriptions(module_dir: Path) -> None:
    for tf_file in sorted(module_dir.glob("*.tf")):
        lines = tf_file.read_text().splitlines()
        block, name, has_description = None, None, False
        for line in lines:
            start = re.match(r'^(variable|output) "([^"]+)" \{', line)
            if start:
                block, name, has_description = start.group(1), start.group(2), False
            elif block and re.match(r"^\s+description\s*=", line):
                has_description = True
            elif block and line == "}":
                if not has_description:
                    errors.append(f"{rel(tf_file)}: {block} '{name}' is missing a description")
                block = None


def check_module_json(module_dir: Path) -> None:
    path = module_dir / "module.json"
    if not path.exists():
        errors.append(f"{rel(module_dir)}: missing module.json")
        return
    meta = json.loads(path.read_text())
    missing = REQUIRED_KEYS - meta.keys()
    if missing:
        errors.append(f"{rel(path)}: missing keys {sorted(missing)}")
        return
    expected_id = "terraform:" + module_dir.relative_to(ROOT).as_posix()
    if meta["id"] != expected_id:
        errors.append(f"{rel(path)}: id '{meta['id']}' should be '{expected_id}'")
    source, version = meta["wraps"]["source"], meta["wraps"]["version"]
    main_tf = (module_dir / "main.tf").read_text()
    if f'source  = "{source}"' not in main_tf or f'version = "{version}"' not in main_tf:
        errors.append(f"{rel(path)}: wraps {source} {version} does not match main.tf")


def main() -> int:
    args = sys.argv[1:]
    skip_init = "--skip-init" in args
    selected = [a for a in args if not a.startswith("--")]

    if selected:
        modules = [ROOT / a for a in selected]
    else:
        modules = sorted(p.parent for p in ROOT.glob("res/*/*/main.tf")) + sorted(
            p.parent for p in ROOT.glob("ptn/*/*/main.tf")
        )
    if not modules:
        errors.append("no modules found")

    check_fmt()
    for module_dir in modules:
        check_descriptions(module_dir)
        check_module_json(module_dir)
        if not skip_init:
            for test_dir in sorted(module_dir.glob("tests/*/")):
                check_test_case(test_dir)

    if errors:
        print("\n".join(errors))
        print(f"\nFAILED: {len(errors)} problem(s)")
        return 1
    print(f"OK: {len(modules)} modules validated")
    return 0


if __name__ == "__main__":
    sys.exit(main())
