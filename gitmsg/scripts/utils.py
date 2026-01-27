#!/usr/bin/env python3
"""Utility helpers shared by gitmsg scripts."""

import json
import subprocess
from pathlib import Path
from typing import Any, Dict, Optional


def get_skill_dir() -> Path:
    return Path(__file__).resolve().parent.parent


def list_rules(skill_dir: Optional[Path] = None) -> Dict[str, Dict[str, Any]]:
    if skill_dir is None:
        skill_dir = get_skill_dir()

    rules_dir = skill_dir / "rules"
    rules: Dict[str, Dict[str, Any]] = {}

    if not rules_dir.exists():
        return rules

    for rule_path in rules_dir.iterdir():
        if not rule_path.is_dir() or rule_path.name.startswith("."):
            continue
        config_path = rule_path / "config.json"
        if config_path.exists():
            with open(config_path, encoding="utf-8") as f:
                rules[rule_path.name] = json.load(f)

    return rules


def get_git_root() -> Optional[Path]:
    try:
        result = subprocess.run(
            ["git", "rev-parse", "--show-toplevel"],
            capture_output=True,
            text=True,
            check=True,
        )
        return Path(result.stdout.strip())
    except subprocess.CalledProcessError:
        return None


def is_git_repo() -> bool:
    return get_git_root() is not None


def get_staged_files() -> list[str]:
    try:
        result = subprocess.run(
            ["git", "diff", "--cached", "--name-only"],
            capture_output=True,
            text=True,
            check=True,
        )
        return [line for line in result.stdout.splitlines() if line]
    except subprocess.CalledProcessError:
        return []


def format_output(data: Any, format_type: str = "json") -> str:
    if format_type == "json":
        return json.dumps(data, indent=2, ensure_ascii=False)
    if format_type == "yaml":
        import yaml  # noqa: F401

        return yaml.dump(data, allow_unicode=True)
    return str(data)
