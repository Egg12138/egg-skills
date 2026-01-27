#!/usr/bin/env python3
"""Lint git commit messages according to configured rules."""

import argparse
import json
import re
from pathlib import Path
from typing import Any, Dict, List


class MessageLinter:
    def __init__(self, skill_dir: Path, rule_name: str) -> None:
        self.skill_dir = skill_dir
        self.rule_name = rule_name
        self.rule_dir = skill_dir / "rules" / rule_name
        if not self.rule_dir.exists():
            raise ValueError(f"Rule '{rule_name}' not found")
        self.lint_rules = self._load_lint_rules()

    def _load_lint_rules(self) -> List[Dict[str, Any]]:
        lint_path = self.rule_dir / "lint-rules.json"
        if not lint_path.exists():
            return []
        with open(lint_path, encoding="utf-8") as f:
            return json.load(f)

    def lint(self, message: str) -> Dict[str, Any]:
        errors: List[Dict[str, Any]] = []
        warnings: List[Dict[str, Any]] = []

        for rule in self.lint_rules:
            result = self._check_rule(message, rule)
            if result["severity"] == "error" and not result.get("passed", True):
                errors.append(result)
            elif result["severity"] == "warning" and not result.get("passed", True):
                warnings.append(result)

        return {
            "valid": len(errors) == 0,
            "errors": errors,
            "warnings": warnings,
            "message": message,
        }

    def _check_rule(self, message: str, rule: Dict[str, Any]) -> Dict[str, Any]:
        rule_type = rule.get("type")
        if rule_type == "regex":
            return self._check_regex(message, rule)
        if rule_type == "length":
            return self._check_length(message, rule)
        if rule_type == "format":
            return self._check_format(message, rule)
        if rule_type == "semantic":
            return self._check_semantic(message, rule)
        return {"severity": "none", "passed": True}

    def _check_regex(self, message: str, rule: Dict[str, Any]) -> Dict[str, Any]:
        pattern = rule.get("pattern")
        if not pattern:
            return {"severity": "none", "passed": True}

        match = re.search(pattern, message, re.MULTILINE)
        passed = bool(match)
        if rule.get("invert"):
            passed = not passed

        return {
            "severity": rule.get("severity", "error"),
            "passed": passed,
            "message": rule.get("message", f"Pattern check failed: {pattern}"),
            "rule": rule.get("name", "regex"),
        }

    def _check_length(self, message: str, rule: Dict[str, Any]) -> Dict[str, Any]:
        lines = message.splitlines()

        subject = lines[0] if lines else ""
        if "max_subject_length" in rule and len(subject) > rule["max_subject_length"]:
            return {
                "severity": rule.get("severity", "error"),
                "passed": False,
                "message": f"Subject line too long: {len(subject)} > {rule['max_subject_length']}",
                "rule": rule.get("name", "subject_length"),
            }

        if "max_line_length" in rule:
            max_len = rule["max_line_length"]
            for idx, line in enumerate(lines[1:], start=2):
                if len(line) > max_len:
                    return {
                        "severity": rule.get("severity", "warning"),
                        "passed": False,
                        "message": f"Line {idx} too long: {len(line)} > {max_len}",
                        "rule": rule.get("name", "line_length"),
                    }

        return {"severity": "none", "passed": True}

    def _check_format(self, message: str, rule: Dict[str, Any]) -> Dict[str, Any]:
        required_format = rule.get("format")
        if required_format == "conventional_commits":
            pattern = r"^(feat|fix|docs|style|refactor|test|chore|perf)(\(.+\))?: .+"
            if not re.match(pattern, message):
                return {
                    "severity": rule.get("severity", "error"),
                    "passed": False,
                    "message": "Message must follow Conventional Commits format",
                    "rule": "conventional_commits",
                }
        return {"severity": "none", "passed": True}

    def _check_semantic(self, message: str, rule: Dict[str, Any]) -> Dict[str, Any]:
        return {
            "severity": rule.get("severity", "info"),
            "passed": True,
            "message": "Semantic check requires LLM review",
            "rule": rule.get("name", "semantic"),
            "needs_llm": True,
            "semantic_rules": rule.get("requirements", []),
        }


def main() -> int:
    parser = argparse.ArgumentParser(description="Lint git commit message")
    parser.add_argument("--rule", required=True, help="Rule name to use")
    parser.add_argument("--message", help="Message to lint")
    parser.add_argument("--file", help="File containing message")
    args = parser.parse_args()

    if args.message:
        message = args.message
    elif args.file:
        message = Path(args.file).read_text(encoding="utf-8")
    else:
        print("Error: Must provide either --message or --file")
        return 1

    script_dir = Path(__file__).resolve().parent
    skill_dir = script_dir.parent

    linter = MessageLinter(skill_dir, args.rule)
    result = linter.lint(message)

    print(json.dumps(result, indent=2, ensure_ascii=False))
    return 0 if result["valid"] else 1


if __name__ == "__main__":
    raise SystemExit(main())
