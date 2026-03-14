#!/usr/bin/env bash
set -euo pipefail

# ─────────────────────────────────────────────────────
# Agile Flow Installer for Claude Code
# ─────────────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="${HOME}/.claude"
RULES_DIR="${CLAUDE_DIR}/rules/common"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info()  { echo -e "${GREEN}[✓]${NC} $1"; }
warn()  { echo -e "${YELLOW}[!]${NC} $1"; }
error() { echo -e "${RED}[✗]${NC} $1"; exit 1; }

echo ""
echo "  Agile Flow for Claude Code"
echo "  ─────────────────────────────"
echo ""

# ── Step 1: Vault location ──────────────────────────
DEFAULT_VAULT="${OBSIDIAN_VAULT_PATH:-}"
if [[ -z "$DEFAULT_VAULT" ]]; then
    if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
        DEFAULT_VAULT="C:\\Obsidian_Vaults"
    else
        DEFAULT_VAULT="${HOME}/Obsidian_Vaults"
    fi
fi

read -rp "Obsidian vault path [${DEFAULT_VAULT}]: " VAULT_PATH
VAULT_PATH="${VAULT_PATH:-$DEFAULT_VAULT}"

if [[ ! -d "$VAULT_PATH" ]]; then
    read -rp "Directory doesn't exist. Create it? [Y/n]: " CREATE
    if [[ "${CREATE:-Y}" =~ ^[Yy]$ ]]; then
        mkdir -p "$VAULT_PATH"
        info "Created vault at $VAULT_PATH"
    else
        error "Vault directory required. Aborting."
    fi
fi

# ── Step 2: Copy rules ──────────────────────────────
mkdir -p "$RULES_DIR"

# Update vault path in rules before copying
sed "s|C:\\\\Obsidian_Vaults|${VAULT_PATH}|g" \
    "${SCRIPT_DIR}/rules/obsidian-workflow.md" > "${RULES_DIR}/obsidian-workflow.md"
cp "${SCRIPT_DIR}/rules/git-workflow.md" "${RULES_DIR}/git-workflow.md"

info "Installed workflow rules to ${RULES_DIR}/"

# ── Step 3: Copy vault templates ─────────────────────
TEMPLATES_DIR="${VAULT_PATH}/_Templates"
mkdir -p "$TEMPLATES_DIR"

for tmpl in "${SCRIPT_DIR}"/templates/vault/*.md; do
    cp "$tmpl" "${TEMPLATES_DIR}/$(basename "$tmpl")"
done

info "Installed vault templates to ${TEMPLATES_DIR}/"

# ── Step 4: Create dashboard if missing ──────────────
DASHBOARD="${VAULT_PATH}/_Dashboard.md"
if [[ ! -f "$DASHBOARD" ]]; then
    cat > "$DASHBOARD" <<'EOF'
# Project Dashboard

## Active Projects

(Run `/init <project-name>` in Claude Code to add a project)

## Templates
- [[_Templates/Epic-template|Epic]]
- [[_Templates/Story-template|Story]]
- [[_Templates/Feature-Spec-template|Feature Spec]]
- [[_Templates/Technical-Spec-template|Technical Spec]]
- [[_Templates/Spike-template|Spike/Research]]
- [[_Templates/Board-template|Sprint Board]]
- [[_Templates/Backlog-template|Product Backlog]]
EOF
    info "Created dashboard at ${DASHBOARD}"
else
    warn "Dashboard already exists, skipping"
fi

# ── Step 5: Add additionalDirectories to settings ────
SETTINGS="${CLAUDE_DIR}/settings.json"
if [[ -f "$SETTINGS" ]]; then
    if grep -q "additionalDirectories" "$SETTINGS"; then
        warn "additionalDirectories already configured in settings.json"
    else
        warn "Add this to your ${SETTINGS} under 'permissions':"
        echo ""
        echo "  \"permissions\": {"
        echo "    \"additionalDirectories\": [\"${VAULT_PATH}\"]"
        echo "  }"
        echo ""
    fi
else
    warn "No settings.json found at ${SETTINGS}. Create it with:"
    echo ""
    echo "  {"
    echo "    \"permissions\": {"
    echo "      \"additionalDirectories\": [\"${VAULT_PATH}\"]"
    echo "    },"
    echo "    \"worktree\": {"
    echo "      \"symlinkDirectories\": [\"node_modules\", \".venv\", \".cache\"]"
    echo "    }"
    echo "  }"
    echo ""
fi

# ── Step 6: Plugin installation hint ─────────────────
echo ""
echo "  ─────────────────────────────────────────────"
echo ""
echo "  Install as Claude Code plugin (for skills):"
echo ""
echo "    # Test locally:"
echo "    claude --plugin-dir ${SCRIPT_DIR}"
echo ""
echo "    # Or add marketplace (after pushing to GitHub):"
echo "    /plugin marketplace add <your-github-user>/claude-agile-flow"
echo ""
echo "  Available commands after install:"
echo "    /agile-flow:init <project>   — Initialize a new project"
echo "    /agile-flow:board            — Show sprint board status"
echo "    /agile-flow:story <desc>     — Create a user story"
echo "    /agile-flow:sprint           — Manage sprints"
echo "    /agile-flow:pickup [story]   — Pick up a story + worktree"
echo "    /agile-flow:done             — Complete story + PR"
echo "    /agile-flow:spike <question> — Research spike"
echo ""

info "Installation complete!"
