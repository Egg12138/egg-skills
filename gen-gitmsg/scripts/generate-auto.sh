#!/bin/bash
# generate-auto.sh - Generate commit message automatically (non-interactive)

set -e

RULE_NAME="$1"
OVERRIDE_AUTHOR="$2"

GITMSG_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RULE_DIR="$GITMSG_ROOT/rules/$RULE_NAME"

# For non-interactive mode, read from git diff or prompt
echo "Non-interactive mode for rule: $RULE_NAME"
echo ""
echo "Please provide the commit message following the $RULE_NAME format:"
echo ""

read -p "Enter commit message: " FULL_MSG

# Run linter if enabled
if [ -f "$RULE_DIR/rule.json" ]; then
    LINT_ENABLED=$(jq -r '.lint_enabled // true' "$RULE_DIR/rule.json")
    if [ "$LINT_ENABLED" = "true" ] && [ -x "$RULE_DIR/lint.sh" ]; then
        TEMP_FILE=$(mktemp)
        echo "$FULL_MSG" > "$TEMP_FILE"
        if ! "$RULE_DIR/lint.sh" "$TEMP_FILE"; then
            echo "❌ Lint failed" >&2
            rm -f "$TEMP_FILE"
            exit 1
        fi
        rm -f "$TEMP_FILE"
    fi
fi

# Commit
git commit -m "$FULL_MSG"
