#!/usr/bin/env python3
"""Generate git commit message context for Claude or other LLMs."""

import argparse
import json
import subprocess
from pathlib import Path
from typing import Dict, Optional


class MessageGenerator:
    def __init__(self, skill_dir: Path, rule_name: str):
        self.skill_dir = skill_dir
        self.rule_name = rule_name
        self.rule_dir = skill_dir / "rules" / rule_name
        if not self.rule_dir.exists():
            raise ValueError(f"Rule '{rule_name}' not found")
        self.config = self._load_config()

    def _load_config(self) -> Dict[str, object]:
        config_path = self.rule_dir / "config.json"
        with open(config_path, encoding="utf-8") as f:
            return json.load(f)

    def generate(
        self,
        author: Optional[str] = None,
        email: Optional[str] = None,
        interactive: Optional[bool] = None,
    ) -> str:
        is_interactive = (
            interactive if interactive is not None else self.config.get("interactive", True)
        )
        diff = self._get_git_diff()
        author_info = self._resolve_author_email(author, email)
        template = self._load_template()

        context = {
            "rule": self.config.get("specification", ""),
            "diff": diff,
            "author": author_info.get("author"),
            "email": author_info.get("email"),
            "template": template,
            "interactive": is_interactive,
        }

        return json.dumps(context, indent=2, ensure_ascii=False)

    def _get_git_diff(self) -> str:
        try:
            result = subprocess.run(
                ["git", "diff", "--cached"],
                capture_output=True,
                text=True,
                check=True,
            )
            return result.stdout
        except subprocess.CalledProcessError:
            return ""

    def _resolve_author_email(
        self, author: Optional[str], email: Optional[str]
    ) -> Dict[str, Optional[str]]:
        result: Dict[str, Optional[str]] = {"author": author, "email": email}
        author_config = self.config.get("author_config", {})

        if "from_file" in author_config and not (result["author"] and result["email"]):
            file_data = self._parse_gitconfig(author_config["from_file"])
            result["author"] = result["author"] or file_data.get("name")
            result["email"] = result["email"] or file_data.get("email")

        if not result["author"]:
            result["author"] = author_config.get("author")
        if not result["email"]:
            result["email"] = author_config.get("email")

        if author_config.get("fetch_on_commit") and not (result["author"] and result["email"]):
            git_data = self._get_git_config()
            result["author"] = result["author"] or git_data.get("name")
            result["email"] = result["email"] or git_data.get("email")

        return result

    def _parse_gitconfig(self, path: str) -> Dict[str, str]:
        try:
            content = Path(path).expanduser().read_text(encoding="utf-8")
        except FileNotFoundError:
            return {}

        result: Dict[str, str] = {}
        in_user_section = False

        for line in content.splitlines():
            line = line.strip()
            if line == "[user]":
                in_user_section = True
                continue
            if line.startswith("[") and line != "[user]":
                in_user_section = False
            if in_user_section and "=" in line:
                key, value = line.split("=", 1)
                key = key.strip()
                value = value.strip()
                if key == "name":
                    result["name"] = value
                elif key == "email":
                    result["email"] = value
        return result

    def _get_git_config(self) -> Dict[str, str]:
        result: Dict[str, str] = {}
        try:
            name = subprocess.run(
                ["git", "config", "user.name"],
                capture_output=True,
                text=True,
                check=True,
            ).stdout.strip()
            if name:
                result["name"] = name
        except subprocess.CalledProcessError:
            pass

        try:
            email = subprocess.run(
                ["git", "config", "user.email"],
                capture_output=True,
                text=True,
                check=True,
            ).stdout.strip()
            if email:
                result["email"] = email
        except subprocess.CalledProcessError:
            pass

        return result

    def _load_template(self) -> str:
        template_path = self.rule_dir / "template.txt"
        if template_path.exists():
            return template_path.read_text(encoding="utf-8")
        return ""


def main() -> None:
    parser = argparse.ArgumentParser(description="Generate git commit message")
    parser.add_argument("--rule", default="RTOS", help="Rule name to use")
    parser.add_argument("--author", help="Author name")
    parser.add_argument("--email", help="Author email")
    parser.add_argument("--interactive", action="store_true", help="Enable interactive mode")
    parser.add_argument(
        "--no-interactive", action="store_true", help="Disable interactive mode"
    )
    args = parser.parse_args()

    script_dir = Path(__file__).resolve().parent
    skill_dir = script_dir.parent

    interactive: Optional[bool] = None
    if args.interactive:
        interactive = True
    elif args.no_interactive:
        interactive = False

    generator = MessageGenerator(skill_dir, args.rule)
    context = generator.generate(author=args.author, email=args.email, interactive=interactive)
    print(context)


if __name__ == "__main__":
    main()
