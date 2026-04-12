Run a health check for this wiki.

Read `CLAUDE.md` and `wiki/SCHEMA.md` first. Treat `wiki/SCHEMA.md` as the canonical mutable schema.

## Workflow

1. Read `wiki/SCHEMA.md`, `wiki/index.md`, and `wiki/log.md`.
2. Run checks required by the schema, including at minimum:
	- missing required metadata
	- non-compliant date formats
	- stale or incomplete `wiki/index.md` coverage
	- broken internal links
	- non-wikilink internal references to wiki pages (should use `[[wikilinks]]`)
	- pages that mention a concept or entity by name without wikilinking to its existing page
	- orphan pages
	- schema misalignment (wrong collection, naming, or page type)
	- collection proliferation warning when collection count exceeds 10
3. Report findings by severity with specific file paths.
4. Apply only safe mechanical fixes. Allowed examples:
	- refresh index entries to reflect current pages
	- add missing required metadata keys with explicit placeholder values
	- normalize date formatting to schema rules
	- repair obviously broken internal links when target is unambiguous
	- convert standard markdown links pointing to wiki pages into `[[wikilinks]]`
5. Do not rewrite substantive claims, conclusions, or synthesis automatically.
6. Append one log entry to `wiki/log.md` with heading format:
	- `## [YYYY-MM-DDTHH:MM:SSZ] lint | <brief-summary>`
7. If `.git` exists at vault root, run:
	- `git add -A && git commit -m "lint: <brief summary>"`

## Constraints

- NEVER modify files in `raw/`.
- NEVER modify or delete files in `output/` unless explicitly user-directed.
- NEVER delete wiki pages unless explicitly user-directed.

## Required Report

Report:
- issues found by severity
- fixes applied
- warnings requiring user decisions
- suggested next investigations or source gaps
