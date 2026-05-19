#!/bin/bash
#
# linux-setup skill installer
#
# Replaces path placeholders in SKILL.md and references/ with actual
# values, then creates symlinks under ~/.claude/skills/ and ~/.codex/skills/
# so the skill is picked up by the respective agents.
#
# Usage: ./install.sh [--kernel-src <path>] [--busybox <path>]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# defaults
KERNEL_SRC="${KERNEL_SRC:-$HOME/tmp/linux}"
BUSYBOX_PATH="${BUSYBOX_PATH:-$HOME/utils/Busybox-static}"

usage() {
    echo "Usage: $0 [OPTIONS]"
    echo "Install the linux-setup skill for claude and codex agents."
    echo ""
    echo "Options:"
    echo "  --kernel-src <path>   Path to linux kernel source tree (default: $KERNEL_SRC)"
    echo "  --busybox <path>      Path to static busybox binary  (default: $BUSYBOX_PATH)"
    echo "  -h, --help            Show this help message"
}

# parse args
while [[ $# -gt 0 ]]; do
    case "$1" in
        --kernel-src) KERNEL_SRC="$2"; shift 2 ;;
        --busybox)    BUSYBOX_PATH="$2"; shift 2 ;;
        -h|--help)    usage; exit 0 ;;
        *) echo "Unknown option: $1"; usage; exit 1 ;;
    esac
done

# prompt interactively if not provided via flags
if [[ -t 0 ]]; then
    echo "=== linux-setup skill installer ==="
    echo ""

    read -r -p "Kernel source tree path [$KERNEL_SRC]: " input
    KERNEL_SRC="${input:-$KERNEL_SRC}"

    read -r -p "Static busybox binary path [$BUSYBOX_PATH]: " input
    BUSYBOX_PATH="${input:-$BUSYBOX_PATH}"
    echo ""
fi

echo "--- Replacing placeholders ---"

# replace {{KERNEL_SRC}} and {{BUSYBOX_PATH}} in all .md files
for f in "$SCRIPT_DIR/SKILL.md" "$SCRIPT_DIR/references"/*.md; do
    if [[ -f "$f" ]]; then
        sed -i "s|{{KERNEL_SRC}}|${KERNEL_SRC}|g" "$f"
        sed -i "s|{{BUSYBOX_PATH}}|${BUSYBOX_PATH}|g" "$f"
        echo "  Updated $f"
    fi
done

echo ""
echo "--- Creating symlinks ---"

# claude
mkdir -p "$HOME/.claude/skills"
ln -sfn "$SCRIPT_DIR" "$HOME/.claude/skills/linux-setup"
echo "  ~/.claude/skills/linux-setup -> $SCRIPT_DIR"

# codex
mkdir -p "$HOME/.codex/skills"
ln -sfn "$SCRIPT_DIR" "$HOME/.codex/skills/linux-setup"
echo "  ~/.codex/skills/linux-setup -> $SCRIPT_DIR"

echo ""
echo "Install complete."
echo "  kernel src: $KERNEL_SRC"
echo "  busybox:    $BUSYBOX_PATH"
