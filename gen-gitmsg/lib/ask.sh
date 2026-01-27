#!/bin/bash
# AskUserQuestion emulator for shell-based interaction

# This file provides AskUserQuestion-like functionality for interactive shell scripts
# When running in Claude Code, these will be replaced by actual AskUserQuestion tool calls

# Present a question with options and get user selection
ask_question() {
    local question="$1"
    local header="$2"
    shift 2
    local options=("$@")

    echo ""
    echo "[$header] $question"
    echo ""

    local i=1
    for opt in "${options[@]}"; do
        echo "  $i) $opt"
        i=$((i + 1))
    done
    echo ""

    read -p "Select [1-${#options[@]}]: " choice

    if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "${#options[@]}" ]; then
        return $choice
    else
        return 255
    fi
}

# Ask a yes/no question
ask_yes_no() {
    local prompt="$1"
    local default="${2:-n}"

    local prompt_str="$prompt"
    if [ "$default" = "y" ]; then
        prompt_str="$prompt_str [Y/n]"
    else
        prompt_str="$prompt_str [y/N]"
    fi

    read -p "$prompt_str: " answer
    answer="${answer:-$default}"

    [[ "$answer" =~ ^[Yy] ]]
}

# Ask for multi-select options
ask_multi_select() {
    local question="$1"
    local header="$2"
    shift 2
    local options=("$@")

    echo ""
    echo "[$header] $question"
    echo ""

    local i=1
    for opt in "${options[@]}"; do
        echo "  [$i] $opt"
        i=$((i + 1))
    done
    echo ""
    echo "Enter numbers separated by commas (e.g., 1,3,4):"

    read -p "> " selections

    # Convert to array
    IFS=',' read -ra selected_indices <<< "$selections"
    for idx in "${selected_indices[@]}"; do
        local i=$((idx - 1))
        if [ "$i" -ge 0 ] && [ "$i" -lt "${#options[@]}" ]; then
            echo "${options[$i]}"
        fi
    done
}

# Toggle selection (select/unselect options)
ask_toggles() {
    local question="$1"
    local header="$2"
    shift 2
    local options=("$@")

    echo ""
    echo "[$header] $question"
    echo "(Toggle with space, confirm with enter)"
    echo ""

    local -a selected=()

    # Simple toggle interface
    local i=1
    for opt in "${options[@]}"; do
        local status="[ ]"
        for sel in "${selected[@]}"; do
            if [ "$sel" = "$opt" ]; then
                status="[x]"
                break
            fi
        done
        echo "  $status $i) $opt"
        i=$((i + 1))
    done
    echo ""

    read -p "Toggle options (e.g., 1,3 to toggle; empty to confirm): " input
    IFS=',' read -ra toggles <<< "$input"

    for toggle in "${toggles[@]}"; do
        local idx=$((toggle - 1))
        if [ "$idx" -ge 0 ] && [ "$idx" -lt "${#options[@]}" ]; then
            local opt="${options[$idx]}"
            local found=false
            for sel in "${selected[@]}"; do
                if [ "$sel" = "$opt" ]; then
                    # Remove from selection
                    selected=("${selected[@]/$opt/}")
                    found=true
                    break
                fi
            done
            if [ "$found" = false ]; then
                selected+=("$opt")
            fi
        fi
    done

    # Output selected options
    printf '%s\n' "${selected[@]}"
}

# Export functions
export -f ask_question
export -f ask_yes_no
export -f ask_multi_select
export -f ask_toggles
