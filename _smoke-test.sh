#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
BOOTSTRAP_SCRIPT="$SCRIPT_DIR/wiki-bootstrap.sh"

if [[ ! -f "$BOOTSTRAP_SCRIPT" ]]; then
  echo "Missing bootstrap script: $BOOTSTRAP_SCRIPT" >&2
  exit 1
fi

temp_root="$(mktemp -d "${TMPDIR:-/tmp}/new-wiki-bootstrap.XXXXXX")"

cleanup() {
  rm -rf "$temp_root"
}

trap cleanup EXIT

assert_exists() {
  local path="$1"
  if [[ ! -e "$path" ]]; then
    echo "Missing expected path: $path" >&2
    exit 1
  fi
}

assert_absent() {
  local path="$1"
  if [[ -e "$path" ]]; then
    echo "Path should not exist: $path" >&2
    exit 1
  fi
}

assert_contains() {
  local path="$1"
  local needle="$2"
  if ! grep -q -- "$needle" "$path"; then
    echo "Expected '$needle' in $path" >&2
    exit 1
  fi
}

assert_shared_assets() {
  local vault_dir="$1"

  assert_exists "$vault_dir/.gitignore"
  assert_exists "$vault_dir/raw/assets/.gitkeep"
  assert_exists "$vault_dir/wiki/SCHEMA.md"
  assert_exists "$vault_dir/wiki/index.md"
  assert_exists "$vault_dir/wiki/log.md"
  assert_exists "$vault_dir/wiki/sources/.gitkeep"
  assert_exists "$vault_dir/wiki/topics/.gitkeep"
  assert_exists "$vault_dir/wiki/decisions/.gitkeep"
  assert_exists "$vault_dir/output/.gitkeep"

  assert_contains "$vault_dir/wiki/SCHEMA.md" "Stable:"
  assert_contains "$vault_dir/wiki/SCHEMA.md" "Not static:"
  assert_contains "$vault_dir/wiki/SCHEMA.md" "[[wikilinks]]"
}

assert_claude_assets() {
  local vault_dir="$1"

  assert_exists "$vault_dir/CLAUDE.md"
  assert_exists "$vault_dir/.claude/commands/wiki-ingest.md"
  assert_exists "$vault_dir/.claude/commands/wiki-query.md"
  assert_exists "$vault_dir/.claude/commands/wiki-lint.md"

  assert_contains "$vault_dir/CLAUDE.md" "wiki/SCHEMA.md"
  assert_contains "$vault_dir/CLAUDE.md" "YYYY-MM-DD"
  assert_contains "$vault_dir/CLAUDE.md" "[[wikilinks]]"
  assert_contains "$vault_dir/.claude/commands/wiki-query.md" "YYYY-MM-DDTHH-MM-SSZ"
  assert_contains "$vault_dir/.claude/commands/wiki-lint.md" "collection count exceeds 10"
}

assert_copilot_assets() {
  local vault_dir="$1"

  assert_exists "$vault_dir/AGENTS.md"
  assert_exists "$vault_dir/.github/copilot-instructions.md"
  assert_exists "$vault_dir/.github/agents/wiki-ingest.agent.md"
  assert_exists "$vault_dir/.github/agents/wiki-query.agent.md"
  assert_exists "$vault_dir/.github/agents/wiki-lint.agent.md"

  assert_contains "$vault_dir/AGENTS.md" "wiki/SCHEMA.md"
  assert_contains "$vault_dir/AGENTS.md" "YYYY-MM-DD"
  assert_contains "$vault_dir/.github/copilot-instructions.md" "wiki/SCHEMA.md"
  assert_contains "$vault_dir/.github/agents/wiki-ingest.agent.md" "wiki/SCHEMA.md"
}

assert_rejects_non_empty() {
  local target_dir="$1"
  mkdir -p "$target_dir"
  touch "$target_dir/.hidden"

  if bash "$BOOTSTRAP_SCRIPT" "$target_dir" >/dev/null 2>/dev/null; then
    echo "Bootstrap unexpectedly succeeded on a non-empty target: $target_dir" >&2
    exit 1
  fi
}

# --- Test 1: default (both) mode ---
bootstrap_output="$temp_root/bootstrap-output.txt"
vault_dir="$temp_root/vault-both"

bash "$BOOTSTRAP_SCRIPT" "$vault_dir" >"$bootstrap_output"
assert_shared_assets "$vault_dir"
assert_claude_assets "$vault_dir"
assert_copilot_assets "$vault_dir"

assert_contains "$bootstrap_output" "Vault initialized at:"
assert_contains "$bootstrap_output" "mode: claude | copilot"
assert_contains "$bootstrap_output" "wiki/SCHEMA.md"
assert_contains "$bootstrap_output" "/wiki-ingest"
assert_contains "$bootstrap_output" "/wiki-query"
assert_contains "$bootstrap_output" "/wiki-lint"

# --- Test 2: claude mode ---
vault_claude="$temp_root/vault-claude"
bash "$BOOTSTRAP_SCRIPT" "$vault_claude" claude >"$temp_root/claude-output.txt"
assert_shared_assets "$vault_claude"
assert_claude_assets "$vault_claude"
assert_absent "$vault_claude/AGENTS.md"
assert_absent "$vault_claude/.github"
assert_contains "$temp_root/claude-output.txt" "mode: claude"

# --- Test 3: copilot mode ---
vault_copilot="$temp_root/vault-copilot"
bash "$BOOTSTRAP_SCRIPT" "$vault_copilot" copilot >"$temp_root/copilot-output.txt"
assert_shared_assets "$vault_copilot"
assert_copilot_assets "$vault_copilot"
assert_absent "$vault_copilot/CLAUDE.md"
assert_absent "$vault_copilot/.claude"
assert_contains "$temp_root/copilot-output.txt" "mode: copilot"

# --- Test 4: invalid mode rejected ---
if bash "$BOOTSTRAP_SCRIPT" "$temp_root/vault-invalid" foobar >/dev/null 2>/dev/null; then
  echo "Bootstrap unexpectedly succeeded with invalid mode 'foobar'" >&2
  exit 1
fi

# --- Test 5: non-empty target rejected ---
assert_rejects_non_empty "$temp_root/non-empty"

# --- Test 6: starter-vault drift check ---
starter_dir="$SCRIPT_DIR/starter-vault"
if [[ ! -d "$starter_dir" ]]; then
  echo "Missing starter-vault directory: $starter_dir" >&2
  exit 1
fi

fresh_vault="$temp_root/vault-drift-check"
bash "$BOOTSTRAP_SCRIPT" "$fresh_vault" >/dev/null
if ! diff -r "$fresh_vault" "$starter_dir" >/dev/null 2>&1; then
  echo "starter-vault is out of date; run 'just rebuild-starter'" >&2
  diff -r "$fresh_vault" "$starter_dir" >&2 || true
  exit 1
fi

echo "Smoke test passed: all agent modes, invalid mode rejection, non-empty target rejection, and starter-vault drift check verified."
