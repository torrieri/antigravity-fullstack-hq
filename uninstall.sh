#!/bin/bash
# uninstall.sh — Full Stack HQ
# Supports: Google Antigravity IDE + Claude Code
# Usage:
#   ./uninstall.sh                  # uninstall both
#   ./uninstall.sh --only-antigravity
#   ./uninstall.sh --only-claude
#   ./uninstall.sh --force          # skip confirmation prompts
#
# Only removes files that were installed from this repository.
# Your own skills/agents/configs are left untouched.

set -e

# ── Colors ────────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

# ── Paths ─────────────────────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

GEMINI_HOME="$HOME/.gemini"
GEMINI_SKILLS_DIR="$GEMINI_HOME/antigravity/skills"
GEMINI_WORKFLOWS_DIR="$GEMINI_HOME/antigravity/workflows"
GEMINI_AGENTS_DIR="$GEMINI_HOME/antigravity/agents"

CLAUDE_HOME="$HOME/.claude"
CLAUDE_SKILLS_DIR="$CLAUDE_HOME/skills"
CLAUDE_AGENTS_DIR="$CLAUDE_HOME/agents"

# ── Flags ─────────────────────────────────────────────────────────────────────
FORCE=false
UNINSTALL_ANTIGRAVITY=true
UNINSTALL_CLAUDE=true

while [[ "$#" -gt 0 ]]; do
    case $1 in
        -f|--force)             FORCE=true ;;
        --only-antigravity)     UNINSTALL_CLAUDE=false ;;
        --only-claude)          UNINSTALL_ANTIGRAVITY=false ;;
        *) echo "Unknown parameter: $1"; exit 1 ;;
    esac
    shift
done

# ── Header ────────────────────────────────────────────────────────────────────
echo ""
echo -e "${CYAN}${BOLD}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}${BOLD}║          FULL STACK HQ — UNINSTALLATION                      ║${NC}"
echo -e "${CYAN}${BOLD}║          Google Antigravity + Claude Code                    ║${NC}"
echo -e "${CYAN}${BOLD}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

# ── Helpers ───────────────────────────────────────────────────────────────────

# remove_repo_files <source_glob_dir> <target_dir> <label>
# Removes target files only if they exist in this repo (installed by install.sh)
removed_count=0
skipped_count=0

remove_repo_files() {
    local src_dir="$1" dst_dir="$2" label="$3"
    local count=0
    for f in "$src_dir"/*.md; do
        [[ -f "$f" ]] || continue
        local name
        name="$(basename "$f")"
        if [[ -f "$dst_dir/$name" ]]; then
            rm "$dst_dir/$name"
            ((count++))
        fi
    done
    removed_count=$((removed_count + count))
    echo -e "  ${GREEN}✓ $label: $count removed${NC}"
}

# remove_repo_dirs <source_dir> <target_dir> <label>
# Removes target directories matching repo skill modules
remove_repo_dirs() {
    local src_dir="$1" dst_dir="$2" label="$3"
    local count=0
    for d in "$src_dir"/*; do
        [[ -d "$d" ]] || continue
        local name
        name="$(basename "$d")"
        if [[ -d "$dst_dir/$name" ]]; then
            rm -rf "$dst_dir/$name"
            ((count++))
        fi
    done
    removed_count=$((removed_count + count))
    echo -e "  ${GREEN}✓ $label: $count removed${NC}"
}

# remove_root_md <target_file> <repo_file>
# Removes ~/.gemini/GEMINI.md or ~/.claude/CLAUDE.md with safety checks
remove_root_md() {
    local target="$1" repo_file="$2" name
    name="$(basename "$target")"

    if [[ ! -f "$target" ]]; then
        echo -e "  ${YELLOW}→ $name not found — skipping${NC}"
        skipped_count=$((skipped_count + 1))
        return
    fi

    if cmp -s "$repo_file" "$target"; then
        rm "$target"
        removed_count=$((removed_count + 1))
        echo -e "  ${GREEN}✓ $name (identical to repo — removed)${NC}"
        return
    fi

    # File was modified after install — ask before deleting
    echo -e "  ${YELLOW}⚠ $name differs from repo version (modified after install?)${NC}"
    if [[ "$FORCE" == true ]]; then
        rm "$target"
        removed_count=$((removed_count + 1))
        echo -e "  ${GREEN}✓ $name removed (--force)${NC}"
        return
    fi
    read -rp "  Delete anyway? (y/N) " resp
    if [[ "$resp" == "y" || "$resp" == "Y" ]]; then
        rm "$target"
        removed_count=$((removed_count + 1))
        echo -e "  ${GREEN}✓ $name removed${NC}"
    else
        skipped_count=$((skipped_count + 1))
        echo -e "  ${NC}→ Keeping $name${NC}"
    fi
}

# cleanup_dir <dir>
# Removes directory only if empty (rmdir fails safely otherwise)
cleanup_dir() {
    [[ -d "$1" ]] && rmdir "$1" 2>/dev/null || true
}

# ──────────────────────────────────────────────────────────────────────────────
# ANTIGRAVITY
# ──────────────────────────────────────────────────────────────────────────────
if [[ "$UNINSTALL_ANTIGRAVITY" == true ]]; then
    echo ""
    echo -e "${BLUE}${BOLD}▸ Uninstalling from Google Antigravity IDE${NC}"
    echo -e "  ${CYAN}Target: ~/.gemini/${NC}"

    if [[ ! -d "$GEMINI_HOME" ]]; then
        echo -e "  ${YELLOW}→ ~/.gemini not found — nothing to do${NC}"
    else
        remove_root_md "$GEMINI_HOME/GEMINI.md" "$SCRIPT_DIR/gemini/GEMINI.md"
        [[ -d "$GEMINI_AGENTS_DIR" ]]   && remove_repo_files "$SCRIPT_DIR/agents"   "$GEMINI_AGENTS_DIR"   "Agents"
        [[ -d "$GEMINI_SKILLS_DIR" ]]   && remove_repo_dirs  "$SCRIPT_DIR/skills"   "$GEMINI_SKILLS_DIR"   "Skills"
        [[ -d "$GEMINI_WORKFLOWS_DIR" ]] && remove_repo_files "$SCRIPT_DIR/workflows" "$GEMINI_WORKFLOWS_DIR" "Workflows"

        # Clean up empty dirs (safe: fails silently if user has other files)
        cleanup_dir "$GEMINI_AGENTS_DIR"
        cleanup_dir "$GEMINI_SKILLS_DIR"
        cleanup_dir "$GEMINI_WORKFLOWS_DIR"
        cleanup_dir "$GEMINI_HOME/antigravity"
    fi
fi

# ──────────────────────────────────────────────────────────────────────────────
# CLAUDE CODE
# ──────────────────────────────────────────────────────────────────────────────
if [[ "$UNINSTALL_CLAUDE" == true ]]; then
    echo ""
    echo -e "${BLUE}${BOLD}▸ Uninstalling from Claude Code${NC}"
    echo -e "  ${CYAN}Target: ~/.claude/${NC}"

    if [[ ! -d "$CLAUDE_HOME" ]]; then
        echo -e "  ${YELLOW}→ ~/.claude not found — nothing to do${NC}"
    else
        remove_root_md "$CLAUDE_HOME/CLAUDE.md" "$SCRIPT_DIR/claude/CLAUDE.md"
        [[ -d "$CLAUDE_AGENTS_DIR" ]] && remove_repo_files "$SCRIPT_DIR/agents" "$CLAUDE_AGENTS_DIR" "Agents"
        [[ -d "$CLAUDE_SKILLS_DIR" ]] && remove_repo_dirs  "$SCRIPT_DIR/skills" "$CLAUDE_SKILLS_DIR" "Skills"

        # Clean up empty dirs (safe: fails silently if user has other files)
        cleanup_dir "$CLAUDE_AGENTS_DIR"
        cleanup_dir "$CLAUDE_SKILLS_DIR"
    fi
fi

# ── Summary ───────────────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}${BOLD}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}${BOLD}║                  UNINSTALLATION COMPLETE!                   ║${NC}"
echo -e "${GREEN}${BOLD}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "  ${GREEN}Removed: $removed_count${NC}  ${YELLOW}Skipped/kept: $skipped_count${NC}"
echo ""
echo -e "${CYAN}Not touched:${NC}"
echo "  • Any skills/agents you added yourself"
echo "  • Other files in ~/.gemini or ~/.claude (history, settings, etc.)"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "  1. Restart Antigravity IDE / Claude Code"
echo "  2. This repository was not modified — reinstall anytime with ./install.sh"
echo ""
