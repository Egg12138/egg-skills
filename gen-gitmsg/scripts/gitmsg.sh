#!/bin/bash
# gitmsg - Generate git commit messages following project-specific rules

set -e

GITMSG_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$GITMSG_ROOT/lib/common.sh"

# Usage
usage() {
    cat << EOF
gitmsg - Generate git commit messages following project-specific rules

Usage:
  gitmsg [options]
  gitmsg --new
  gitmsg --default-rule <NAME>
  gitmsg --rule <NAME> [--author <AUTHOR>]

Options:
  -h, --help              Show this help message
  -n, --new               Interactive creation of a new rule
  -d, --default-rule NAME Set default rule for this repository
  -r, --rule NAME         Use specific rule instead of default
  -a, --author AUTHOR     Override author for this commit
  --dry-run               Show message without committing
  --no-lint               Skip linting
  --list                  List available rules and highlight defaults

Examples:
  gitmsg                              # Use default rule
  gitmsg --rule RTOS                   # Use RTOS rule
  gitmsg --new                        # Create a new rule interactively
  gitmsg --default-rule CONVENTIONAL  # Set CONVENTIONAL as default
  gitmsg --rule HULK --author "John Doe"  # Override author

EOF
}

# Print the list of available rules and annotate defaults.
print_rule_list() {
    local repo_default global_default rules rule
    repo_default=$(get_default_rule)
    global_default=$(get_global_default_rule)
    rules=$(list_rules)

    echo "Available rules:"

    if [ -z "$rules" ]; then
        echo "  (none)"
        return
    fi

    while IFS= read -r rule; do
        [ -z "$rule" ] && continue
        local labels=()

        if [ -n "$global_default" ] && [ "$rule" = "$global_default" ]; then
            labels+=("default global")
        fi
        if [ -n "$repo_default" ] && [ "$rule" = "$repo_default" ]; then
            labels+=("default for CWD")
        fi

        local suffix=""
        if [ ${#labels[@]} -gt 0 ]; then
            suffix=" (${labels[0]}"
            for label in "${labels[@]:1}"; do
                suffix+=", $label"
            done
            suffix+=")"
        fi

        echo "  $rule$suffix"
    done <<< "$rules"
}

# Parse arguments
RULE=""
AUTHOR=""
DRY_RUN=false
NO_LINT=false
NEW_RULE=false
LIST_RULES=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            usage
            exit 0
            ;;
        -n|--new)
            NEW_RULE=true
            shift
            ;;
        -d|--default-rule)
            DEFAULT_RULE="$2"
            set_default_rule "$2"
            echo "Default rule set to: $2"
            exit 0
            ;;
        -r|--rule)
            RULE="$2"
            shift 2
            ;;
        -a|--author)
            AUTHOR="$2"
            shift 2
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --no-lint)
            NO_LINT=true
            shift
            ;;
        --list)
            LIST_RULES=true
            shift
            ;;
        *)
            echo "Unknown option: $1" >&2
            usage
            exit 1
            ;;
    esac
done

# Handle listing requests
if [ "$LIST_RULES" = true ]; then
    print_rule_list
    exit 0
fi

# Create new rule interactively
if [ "$NEW_RULE" = true ]; then
    exec "$GITMSG_ROOT/scripts/new-rule.sh"
fi

# Determine which rule to use
if [ -z "$RULE" ]; then
    RULE=$(get_default_rule)
fi

if [ -z "$RULE" ]; then
    echo "No rule specified and no default rule set." >&2
    echo "Use 'gitmsg --default-rule <NAME>' to set a default," >&2
    echo "or 'gitmsg --rule <NAME>' to specify a rule." >&2
    echo "" >&2
    echo "Available rules:"
    list_rules | sed 's/^/  /'
    exit 1
fi

# Check rule exists
if ! rule_exists "$RULE"; then
    echo "Rule '$RULE' not found." >&2
    echo "" >&2
    echo "Available rules:"
    list_rules | sed 's/^/  /'
    exit 1
fi

# Load rule metadata
METADATA=$(get_rule_metadata "$RULE")
INTERACTIVE=$(echo "$METADATA" | jq -r '.interactive // true')

# If interactive, prompt for commit details
if [ "$INTERACTIVE" = "true" ]; then
    exec "$GITMSG_ROOT/scripts/generate-interactive.sh" "$RULE" "$AUTHOR"
else
    exec "$GITMSG_ROOT/scripts/generate-auto.sh" "$RULE" "$AUTHOR"
fi
