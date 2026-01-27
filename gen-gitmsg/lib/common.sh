#!/bin/bash
# Common functions for gitmsg skill

# Get the gitmsg root directory
GITMSG_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Get default rule from config
get_default_rule() {
    local config_file="$GITMSG_ROOT/../.claude/gitmsg.json"
    if [ -f "$config_file" ]; then
        jq -r '.default_rule // empty' "$config_file"
    fi
}

# Set default rule
set_default_rule() {
    local rule_name="$1"
    local config_dir="$GITMSG_ROOT/../.claude"
    local config_file="$config_dir/gitmsg.json"

    mkdir -p "$config_dir"
    if [ -f "$config_file" ]; then
        jq --arg rule "$rule_name" '.default_rule = $rule' "$config_file" > "${config_file}.tmp"
        mv "${config_file}.tmp" "$config_file"
    else
        echo "{\"default_rule\": \"$rule_name\"}" > "$config_file"
    fi
}

# Check if rule exists
rule_exists() {
    local rule_name="$1"
    [ -d "$GITMSG_ROOT/rules/$rule_name" ]
}

# List all available rules
list_rules() {
    local rules_dir="$GITMSG_ROOT/rules"
    if [ -d "$rules_dir" ]; then
        find "$rules_dir" -mindepth 1 -maxdepth 1 -type d | sed 's|.*/||' | sort
    fi
}

# Get rule metadata
get_rule_metadata() {
    local rule_name="$1"
    local metadata_file="$GITMSG_ROOT/rules/$rule_name/metadata.json"
    if [ -f "$metadata_file" ]; then
        cat "$metadata_file"
    fi
}

# Get git config values
get_git_config() {
    local key="$1"
    git config --global "$key" 2>/dev/null || echo ""
}

# Validate rule name (alphanumeric, hyphen, underscore)
validate_rule_name() {
    local name="$1"
    [[ "$name" =~ ^[a-zA-Z0-9_-]+$ ]]
}

# Check for duplicate rule
check_duplicate_rule() {
    local rule_name="$1"
    rule_exists "$rule_name"
}

# Generate unique rule name if duplicate
generate_unique_name() {
    local base_name="$1"
    local counter=1
    local unique_name="${base_name}-${counter}"

    while rule_exists "$unique_name"; do
        counter=$((counter + 1))
        unique_name="${base_name}-${counter}"
    done

    echo "$unique_name"
}

# Read multi-line input until empty line
read_multiline() {
    local prompt="$1"
    echo "$prompt"
    echo "(Enter empty line to finish input)"
    echo ""

    local line
    local content=""
    while IFS= read -r line; do
        if [ -z "$line" ]; then
            break
        fi
        content="${content}${line}"$'\n'
    done

    echo "$content"
}

# Create rule directory structure
create_rule_structure() {
    local rule_name="$1"
    local rule_dir="$GITMSG_ROOT/rules/$rule_name"

    mkdir -p "$rule_dir"/{examples,lib}
    touch "$rule_dir"/{rule.md,rule.json,template.md,pattern.yaml,lint.sh,metadata.json}
}

# Read the global default rule from the default_rule file
get_global_default_rule() {
    local default_file="$GITMSG_ROOT/default_rule"
    if [ -f "$default_file" ]; then
        head -n 1 "$default_file" | tr -d '\r\n'
    fi
}

# Export functions
export -f get_default_rule
export -f set_default_rule
export -f rule_exists
export -f list_rules
export -f get_rule_metadata
export -f get_git_config
export -f validate_rule_name
export -f check_duplicate_rule
export -f generate_unique_name
export -f read_multiline
export -f create_rule_structure
export -f get_global_default_rule
