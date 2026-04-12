# Wiki Schema

This is the canonical mutable schema for `wiki/`.

- Stable: all ingest, query, and lint workflows read this file first.
- Not static: this schema can evolve with explicit user approval.

## Core Structure

- `wiki/index.md` - content-oriented catalog of wiki pages.
- `wiki/log.md` - append-only operation log.
- `wiki/<collection>/` - collection directories.

Collection names must be short, descriptive, and kebab-case.
Collection count above 10 is a lint warning, not a hard failure.

## Default Collections

These defaults are intentionally small and durable:

- `wiki/sources/` - source summaries derived from `raw/`.
- `wiki/topics/` - synthesized topic pages.
- `wiki/decisions/` - conclusions, tradeoffs, and decision records.

You may add or rename collections if the domain requires it, but keep the schema compact.

## Durable Page Types

| Type | Typical collection | Purpose |
| --- | --- | --- |
| `source-summary` | `wiki/sources/` | Structured summary of a raw source |
| `topic` | `wiki/topics/` | Evolving synthesis across sources |
| `decision` | `wiki/decisions/` | Chosen stance, recommendation, or judgment |

Note: `query-result` pages live in `output/`, not `wiki/`. They are not durable wiki pages and follow their own frontmatter defined by the query workflow.

## Required Frontmatter For Durable Pages

All durable wiki pages require:

- `title`
- `type`
- `created`
- `updated`
- `status`
- `sources`

Optional recommended field:

- `tags` - list of tags for Obsidian Dataview queries and tag-based browsing

Date format for `created` and `updated`: `YYYY-MM-DD`

Recommended `status` values: `draft`, `active`, `superseded`, `blocked`

### Additional Required Fields By Type

- `source-summary`: `raw_path`, `source_type`
- `decision`: `decision_date`

Recommended `source_type` values: `article`, `paper`, `book`, `transcript`, `report`, `webpage`, `other`

## Naming Conventions

- Collection directories: kebab-case.
- Wiki page filenames: kebab-case.
- Source summary filenames: `YYYY-MM-DD--<source-slug>.md`
- Query output filenames: `YYYY-MM-DDTHH-MM-SSZ--<query-slug>.md`

## Link Format

Internal links between wiki pages use Obsidian wikilink syntax:

- Basic link: `[[collection/page-name]]`
- Display-text alias: `[[collection/page-name|Display Text]]`
- Anchor link: `[[collection/page-name#heading]]`

Never wikilink into `raw/`. Reference raw sources via `raw_path` frontmatter.
Output files may use wikilinks to reference wiki pages.

## Source Handling

Attempt to read and parse any source file in `raw/`, regardless of format.
If a source cannot be parsed (binary, unsupported format, corrupted), create a `source-summary` page with `status: blocked` and note the failure reason in the page body.
Report unparseable sources under "unresolved issues or schema gaps" in the ingest report.

## Ingest Rules

- Never modify `raw/`.
- Detect unprocessed sources by checking whether each raw file is represented by a `source-summary` page with matching `raw_path`.
- Place each new page into the most fitting existing collection. If no existing collection is a logical fit, create a new collection directory and document it in this schema.
- On ingest, update existing pages when possible instead of creating near-duplicates.
- Keep provenance explicit by linking claims to `source-summary` pages.
- Update `wiki/index.md` and append a log entry to `wiki/log.md`.

## Query Rules

- Read `wiki/index.md` first, then follow relevant links.
- Ground responses in wiki content only.
- Write each query result as a new immutable file in `output/`.
- Do not modify wiki content pages during query workflow.
- Append one query log entry to `wiki/log.md`.

## Lint Rules

Lint checks at minimum:

- required metadata presence
- `YYYY-MM-DD` page-date compliance
- index coverage and stale entries
- broken internal links
- non-wikilink internal references to wiki pages (should use `[[wikilinks]]`)
- pages that mention a concept or entity by name without wikilinking to its existing page
- orphan pages
- schema alignment (path, type, naming)
- collection count warning when count exceeds 10

Lint may apply only safe mechanical fixes (metadata keys, date normalization, index alignment, unambiguous link repairs).
Lint must not rewrite substantive claims without user direction.

## Log Format

Every ingest, query, and lint run appends one entry in this heading format:

`## [YYYY-MM-DDTHH:MM:SSZ] <operation> | <summary>`

Use ISO 8601 timestamps in log headings.

Recommended fields under each log entry:

- `status: success | partial | blocked`
- `inputs: ...`
- `outputs: ...`
- `notes: ...`

## Index Entry Format

Each entry in `wiki/index.md` uses this format:

`- [[collection/page]] - one-line summary | type: <type> | updated: <YYYY-MM-DD> | sources: <count>`

`wiki/index.md` has one section per collection, matching the Default Collections. New collections get their own section.

## Schema Evolution

When this schema changes:

1. update this file
2. update `wiki/index.md` structure if needed
3. append a log entry describing the schema update
4. run lint to verify alignment
