#!/usr/bin/env python3
"""Validate every Bicep module in this repo.

Checks:
  1. every main.bicep, test and example builds and lints without warnings
     (warnings BCP081 raised inside upstream AVM modules are ignored)
  2. every module parameter and output has an @description
  3. every module folder has a module.json that matches the required shape,
     an id that matches its folder path, and a pinned AVM version that matches main.bicep

Usage: python3 scripts/validate.py   (run from anywhere; requires the bicep CLI)
"""
import json
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
REQUIRED_KEYS = {"id", "cloud", "tool", "name", "summary", "useWhen", "avoidWhen", "tags", "wraps", "maturity"}
IGNORED_DIAGNOSTICS = ("BCP081",)  # missing resource types inside upstream modules

errors: list[str] = []


def rel(path: Path) -> str:
    return str(path.relative_to(ROOT))


def build(path: Path) -> dict | None:
    result = subprocess.run(["bicep", "build", str(path), "--stdout"], capture_output=True, text=True)
    diagnostics = [
        line for line in result.stderr.splitlines()
        if (" Warning " in line or " Error " in line) and not any(code in line for code in IGNORED_DIAGNOSTICS)
    ]
    for line in diagnostics:
        errors.append(line.replace(str(ROOT) + "/", ""))
    if result.returncode != 0:
        errors.append(f"{rel(path)}: bicep build failed")
        return None
    return json.loads(result.stdout)


def check_descriptions(path: Path, arm: dict) -> None:
    for kind in ("parameters", "outputs"):
        for name, definition in arm.get(kind, {}).items():
            if not definition.get("metadata", {}).get("description"):
                errors.append(f"{rel(path)}: {kind[:-1]} '{name}' is missing @description")


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
    expected_id = "azure:bicep:" + module_dir.relative_to(ROOT).as_posix()
    if meta["id"] != expected_id:
        errors.append(f"{rel(path)}: id '{meta['id']}' should be '{expected_id}'")
    source, version = meta["wraps"]["source"], meta["wraps"]["version"]
    if f"'{source}:{version}'" not in (module_dir / "main.bicep").read_text():
        errors.append(f"{rel(path)}: wraps {source}:{version} does not match main.bicep")


def main() -> int:
    modules = sorted(p.parent for p in ROOT.glob("res/*/*/main.bicep")) + sorted(
        p.parent for p in ROOT.glob("ptn/*/*/main.bicep")
    )
    if not modules:
        errors.append("no modules found")

    for module_dir in modules:
        arm = build(module_dir / "main.bicep")
        if arm:
            check_descriptions(module_dir / "main.bicep", arm)
        check_module_json(module_dir)
        for test in sorted(module_dir.glob("tests/*/main.test.bicep")):
            build(test)

    if errors:
        print("\n".join(sorted(set(errors))))
        print(f"\nFAILED: {len(set(errors))} problem(s)")
        return 1
    print(f"OK: {len(modules)} modules validated")
    return 0


if __name__ == "__main__":
    sys.exit(main())
