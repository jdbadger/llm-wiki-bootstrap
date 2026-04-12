# LLM Wiki Bootstrap

A Bootstrapper for Schema-Driven LLM Wiki Vaults

Inspired by [Andrej Karpathy's LLM Wiki gist](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f): keep raw sources immutable, maintain a structured wiki that compounds over time, and generate grounded answers from that maintained knowledge base instead of starting from scratch for every question.

## What This Creates

Running the bootstrap script creates a new vault with this structure (default layout with both agent ecosystems; pass `claude` or `copilot` to install only one):

```text
<vault>/
	CLAUDE.md
	AGENTS.md
	.gitignore
	raw/
		assets/
			.gitkeep
	wiki/
		SCHEMA.md
		index.md
		log.md
		sources/
			.gitkeep
		topics/
			.gitkeep
		decisions/
			.gitkeep
	output/
		.gitkeep
	.claude/
		commands/
			wiki-ingest.md
			wiki-query.md
			wiki-lint.md
	.github/
		copilot-instructions.md
		agents/
			wiki-ingest.agent.md
			wiki-query.agent.md
			wiki-lint.agent.md
```

## Install

### Clone and bootstrap

Clone the repo and use the bootstrap script to create vaults with optional agent-mode selection:

```bash
git clone https://github.com/jdbadger/llm-wiki-bootstrap.git
cd llm-wiki-bootstrap
./wiki-bootstrap.sh /path/to/new-vault [claude|copilot]
```

> **Windows users:** Run the script via [WSL](https://learn.microsoft.com/en-us/windows/wsl/install), [Git Bash](https://git-scm.com/downloads/win), or any POSIX-compatible shell.

Bootstrap behavior:

- Requires at least one argument: target vault directory.
- Optional second argument selects agent mode: `claude`, `copilot`, or omit for both (default).
- Fails if the target exists and is not a directory.
- Fails if the target directory is non-empty.
- Does not run `git init`.

**-OR-**

### Copy the starter vault

The quickest way to get started — no script execution needed.

**Via GitHub:** Download the [ZIP archive](https://github.com/jdbadger/llm-wiki-bootstrap/archive/refs/heads/main.zip), extract the `starter-vault/` folder, and move it wherever you like.

**Via curl:**

```bash
mkdir /path/to/my-vault
curl -fsSL https://github.com/jdbadger/llm-wiki-bootstrap/archive/refs/heads/main.tar.gz \
  | tar xz --strip-components=2 -C /path/to/my-vault llm-wiki-bootstrap-main/starter-vault
```

## How to Connect Your Vault to Obsidian

The bootstrapped vault is designed to work with [Obsidian](https://obsidian.md/), a free markdown knowledge base app.

1. Download and install [Obsidian](https://obsidian.md/) if you haven't already.
2. Open Obsidian, choose **Open folder as vault**, and select the directory created by the bootstrap script.
3. Confirm that Obsidian can see `wiki/`, `raw/`, `output/`, and the generated root files.
4. Use `wiki/index.md` as the main entry point for browsing.
5. As the wiki grows, use backlinks, local graph, and graph view to inspect coverage and relationships between pages.
6. Store images, PDFs, or other attachments under `raw/assets/` so the vault stays portable and the schema can reference them consistently.

> **Tip:** The [Obsidian Web Clipper](https://obsidian.md/clipper) browser extension can save web pages directly into `raw/`, making it easy to capture source material for ingest.

## Workflow Model

- `raw/` is immutable source material.
- `wiki/` is agent-maintained knowledge.
- `output/` stores immutable query deliverables unless user-directed.
- `wiki/SCHEMA.md` is stable in role, but editable over time.
