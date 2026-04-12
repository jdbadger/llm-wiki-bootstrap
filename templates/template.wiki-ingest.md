Ingest new source material from `raw/` into the wiki.

Read `CLAUDE.md` and `wiki/SCHEMA.md` first. Treat `wiki/SCHEMA.md` as the canonical mutable schema.

## Workflow

1. Read `wiki/SCHEMA.md`, `wiki/index.md`, and `wiki/log.md`.
2. Detect unprocessed sources in `raw/` using the source mapping rules in `wiki/SCHEMA.md`.
3. For each unprocessed source:
	- Read the full source.
	- Create or update the schema-defined source summary page.
	- Place the page into the most fitting existing collection. If no collection fits, create a new one.
	- Update related durable wiki pages required by the schema.
	- Add `[[wikilinks]]` to connect the page to related wiki pages — both from the new page and by updating existing pages that should reference it.
	- If a source cannot be parsed, create a source-summary page with `status: blocked` and report the failure.
	- Preserve provenance according to schema rules.
4. Update `wiki/index.md` so new and changed pages are represented.
5. Append one log entry to `wiki/log.md` with heading format:
	- `## [YYYY-MM-DDTHH:MM:SSZ] ingest | <source-or-batch-summary>`
6. If `.git` exists at vault root, run:
	- `git add -A && git commit -m "ingest: <brief description>"`

## Constraints

- NEVER modify files in `raw/`.
- NEVER modify or delete files in `output/` unless explicitly user-directed.
- NEVER invent facts not grounded in wiki pages and source material.
- Prefer updating existing pages over creating duplicates.

## Required Report

Report:
- sources processed
- pages created
- pages updated
- unresolved issues or schema gaps
