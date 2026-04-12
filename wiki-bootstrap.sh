#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="$SCRIPT_DIR/templates"

usage() {
	cat <<'EOF'
Usage: ./wiki-bootstrap.sh /path/to/new-wiki-vault [claude|copilot]

Creates a new LLM wiki vault with:
- raw/ (immutable sources)
- wiki/ (maintained knowledge base)
- output/ (generated deliverables)
- Agent-specific command/workflow files

Optional second argument:
  claude   Install only Claude Code assets (CLAUDE.md, .claude/commands/)
  copilot  Install only GitHub Copilot assets (AGENTS.md, .github/agents/)
  (none)   Install both (default)

The target directory must not already contain files.
EOF
}

required_templates=(
	"template.CLAUDE.md"
	"template.AGENTS.md"
	"template.copilot-instructions.md"
	"template.SCHEMA.md"
	"template.index.md"
	"template.log.md"
	"template.wiki-ingest.md"
	"template.wiki-query.md"
	"template.wiki-lint.md"
	"template.wiki-ingest.agent.md"
	"template.wiki-query.agent.md"
	"template.wiki-lint.agent.md"
)

if [[ $# -lt 1 || $# -gt 2 ]]; then
	usage
	exit 1
fi

VAULT_DIR="$1"
AGENT_MODE="${2:-claude | copilot}"

if [[ "$AGENT_MODE" != "claude" && "$AGENT_MODE" != "copilot" && "$AGENT_MODE" != "claude | copilot" ]]; then
	echo "Error: invalid agent mode '$AGENT_MODE'. Must be 'claude', 'copilot', or omitted for both." >&2
	exit 1
fi

if [[ -e "$VAULT_DIR" && ! -d "$VAULT_DIR" ]]; then
	echo "Error: target exists and is not a directory: $VAULT_DIR" >&2
	exit 1
fi

if [[ -d "$VAULT_DIR" ]] && find "$VAULT_DIR" -mindepth 1 -maxdepth 1 -print -quit | grep -q .; then
	echo "Error: target directory is not empty: $VAULT_DIR" >&2
	exit 1
fi

if [[ ! -d "$TEMPLATE_DIR" ]]; then
	echo "Error: template directory not found: $TEMPLATE_DIR" >&2
	exit 1
fi

for template in "${required_templates[@]}"; do
	if [[ ! -f "$TEMPLATE_DIR/$template" ]]; then
		echo "Error: missing template: $TEMPLATE_DIR/$template" >&2
		exit 1
	fi
done

mkdir -p "$VAULT_DIR/raw/assets"
mkdir -p "$VAULT_DIR/wiki"
mkdir -p "$VAULT_DIR/wiki/sources"
mkdir -p "$VAULT_DIR/wiki/topics"
mkdir -p "$VAULT_DIR/wiki/decisions"
mkdir -p "$VAULT_DIR/output"

if [[ "$AGENT_MODE" == "claude" || "$AGENT_MODE" == "claude | copilot" ]]; then
	mkdir -p "$VAULT_DIR/.claude/commands"
fi

if [[ "$AGENT_MODE" == "copilot" || "$AGENT_MODE" == "claude | copilot" ]]; then
	mkdir -p "$VAULT_DIR/.github/agents"
fi

touch "$VAULT_DIR/raw/assets/.gitkeep"
touch "$VAULT_DIR/output/.gitkeep"
touch "$VAULT_DIR/wiki/sources/.gitkeep"
touch "$VAULT_DIR/wiki/topics/.gitkeep"
touch "$VAULT_DIR/wiki/decisions/.gitkeep"

cp "$TEMPLATE_DIR/template.SCHEMA.md" "$VAULT_DIR/wiki/SCHEMA.md"
cp "$TEMPLATE_DIR/template.index.md" "$VAULT_DIR/wiki/index.md"
cp "$TEMPLATE_DIR/template.log.md" "$VAULT_DIR/wiki/log.md"

if [[ "$AGENT_MODE" == "claude" || "$AGENT_MODE" == "claude | copilot" ]]; then
	cp "$TEMPLATE_DIR/template.CLAUDE.md" "$VAULT_DIR/CLAUDE.md"
	cp "$TEMPLATE_DIR/template.wiki-ingest.md" "$VAULT_DIR/.claude/commands/wiki-ingest.md"
	cp "$TEMPLATE_DIR/template.wiki-query.md" "$VAULT_DIR/.claude/commands/wiki-query.md"
	cp "$TEMPLATE_DIR/template.wiki-lint.md" "$VAULT_DIR/.claude/commands/wiki-lint.md"
fi

if [[ "$AGENT_MODE" == "copilot" || "$AGENT_MODE" == "claude | copilot" ]]; then
	cp "$TEMPLATE_DIR/template.AGENTS.md" "$VAULT_DIR/AGENTS.md"
	cp "$TEMPLATE_DIR/template.copilot-instructions.md" "$VAULT_DIR/.github/copilot-instructions.md"
	cp "$TEMPLATE_DIR/template.wiki-ingest.agent.md" "$VAULT_DIR/.github/agents/wiki-ingest.agent.md"
	cp "$TEMPLATE_DIR/template.wiki-query.agent.md" "$VAULT_DIR/.github/agents/wiki-query.agent.md"
	cp "$TEMPLATE_DIR/template.wiki-lint.agent.md" "$VAULT_DIR/.github/agents/wiki-lint.agent.md"
fi

cat > "$VAULT_DIR/.gitignore" <<'EOF'
# Obsidian local state
.obsidian/

# Obsidian trash
.trash/

# OS junk
.DS_Store
Thumbs.db
desktop.ini
EOF

echo "Vault initialized at: $VAULT_DIR (mode: $AGENT_MODE)"
echo
echo "Next steps:"
echo "1. Open the vault in your LLM agent (Claude Code, Copilot, etc.)."
echo "2. Review and customize wiki/SCHEMA.md."
echo "3. Add source files to raw/."
echo "4. Run /wiki-ingest, /wiki-query, and /wiki-lint."
echo
echo "Note: this script does not run git init. If the vault has a .git directory,"
echo "the generated workflows will commit after ingest/query/lint operations."
