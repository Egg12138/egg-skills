#!/bin/bash
# generate-interactive.sh - Generate commit message interactively based on rule

set -e

RULE_NAME="$1"
OVERRIDE_AUTHOR="$2"

GITMSG_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$GITMSG_ROOT/lib/common.sh"

RULE_DIR="$GITMSG_ROOT/rules/$RULE_NAME"
RULE_JSON="$RULE_DIR/rule.json"

if [ ! -f "$RULE_JSON" ]; then
    echo "Error: Rule metadata not found: $RULE_JSON" >&2
    exit 1
fi

# Load rule configuration
TYPES=$(jq -r '.types[]? // empty' "$RULE_JSON")
SCOPES=$(jq -r '.scopes[]? // empty' "$RULE_JSON")
METADATA=$(cat "$RULE_DIR/metadata.json" 2>/dev/null || echo "{}")

# Determine author
AUTHOR=$(echo "$METADATA" | jq -r '.author // empty')
if [ -z "$AUTHOR" ] || [ -n "$OVERRIDE_AUTHOR" ]; then
    AUTHOR="${OVERRIDE_AUTHOR:-$(git config user.name)}"
fi

EMAIL=$(echo "$METADATA" | jq -r '.email // empty')
if [ -z "$EMAIL" ]; then
    EMAIL=$(git config user.email)
fi

echo "=== Generating Commit Message (Rule: $RULE_NAME) ==="
echo "Author: $AUTHOR <$EMAIL>"
echo ""

# Collect type
if [ -n "$TYPES" ]; then
    echo "Select type:"
    i=1
    echo "$TYPES" | while read -r type; do
        echo "  $i) $type"
        i=$((i + 1))
    done
    echo ""
    read -p "Select type: " type_choice
    TYPE=$(echo "$TYPES" | sed -n "${type_choice}p")
else
    read -p "Type: " TYPE
fi

# Collect scope
if [ -n "$SCOPES" ]; then
    echo ""
    echo "Select scope (or press Enter to skip):"
    i=1
    echo "$SCOPES" | while read -r scope; do
        echo "  $i) $scope"
        i=$((i + 1))
    done
    read -p "Select scope: " scope_choice
    SCOPE=$(echo "$SCOPES" | sed -n "${scope_choice}p")
else
    read -p "Scope (optional): " SCOPE
fi

# Subject
echo ""
read -p "Subject (imperative mood, no period): " SUBJECT

# Build header
if [ -n "$SCOPE" ]; then
    HEADER="$TYPE($SCOPE): $SUBJECT"
else
    HEADER="$TYPE: $SUBJECT"
fi

# Body
echo ""
echo "Body (press Enter on empty line to finish):"
BODY=""
while IFS= read -r line; do
    [ -z "$line" ] && break
    BODY="${BODY}${line}"$'\n'
done

# Footer
echo ""
echo "Footer (DST, AR, etc. - empty line to finish):"
FOOTER=""
while IFS= read -r line; do
    [ -z "$line" ] && break
    FOOTER="${FOOTER}${line}"$'\n'
done

# Build full message
FULL_MSG="$HEADER"
if [ -n "$BODY" ]; then
    FULL_MSG="$FULL_MSG"$'\n\n'"$BODY"
fi
if [ -n "$FOOTER" ]; then
    FULL_MSG="$FULL_MSG"$'\n\n'"$FOOTER"
fi

echo ""
echo "=== Generated Commit Message ==="
echo ""
echo "$FULL_MSG"
echo ""

# Ask for confirmation
read -p "Use this message? [y/N] " confirm
if [[ ! "$confirm" =~ ^[Yy] ]]; then
    echo "Aborted."
    exit 1
fi

# Run linter if enabled
LINT_ENABLED=$(jq -r '.lint_enabled // true' "$RULE_JSON")
if [ "$LINT_ENABLED" = "true" ] && [ -x "$RULE_DIR/lint.sh" ]; then
    TEMP_FILE=$(mktemp)
    echo "$FULL_MSG" > "$TEMP_FILE"
    if "$RULE_DIR/lint.sh" "$TEMP_FILE"; then
        echo "✅ Lint passed"
    else
        echo "❌ Lint failed" >&2
        read -p "Commit anyway? [y/N] " force
        if [[ ! "$force" =~ ^[Yy] ]]; then
            rm -f "$TEMP_FILE"
            exit 1
        fi
    fi
    rm -f "$TEMP_FILE"
fi

# Store metadata
HISTORY_DIR="$GITMSG_ROOT/../.claude"
mkdir -p "$HISTORY_DIR"
HISTORY_FILE="$HISTORY_DIR/gitmsg-history.json"

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
ENTRY=$(cat << EOF
{
  "timestamp": "$TIMESTAMP",
  "rule": "$RULE_NAME",
  "author": "$AUTHOR",
  "email": "$EMAIL",
  "message": $(echo "$FULL_MSG" | jq -Rs .)
}
EOF
)

if [ -f "$HISTORY_FILE" ]; then
    jq ". += [$ENTRY]" "$HISTORY_FILE" > "${HISTORY_FILE}.tmp"
    mv "${HISTORY_FILE}.tmp" "$HISTORY_FILE"
else
    echo "[$ENTRY]" > "$HISTORY_FILE"
fi

# Commit
git commit -m "$FULL_MSG"
