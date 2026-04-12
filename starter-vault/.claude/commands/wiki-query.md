Answer this question using wiki content: $ARGUMENTS

Read `CLAUDE.md` and `wiki/SCHEMA.md` first. Treat `wiki/SCHEMA.md` as the canonical mutable schema.

## Workflow

1. Read `wiki/SCHEMA.md`, `wiki/index.md`, and relevant linked pages.
2. Synthesize an answer grounded strictly in wiki content.
	- Use `[[wikilinks]]` when referencing wiki pages in the response body.
3. Write the result as a new markdown file in `output/` named:
	- `YYYY-MM-DDTHH-MM-SSZ--<query-slug>.md`
4. Include frontmatter at minimum:

	```yaml
	---
	title: "Query: <short summary>"
	type: query-result
	created: YYYY-MM-DD
	query: "<original question>"
	pages-consulted:
	  - "[[path/to/page]]"
	---
	```

5. Do not modify wiki content pages during query workflow.
6. Append one log entry to `wiki/log.md` with heading format:
	- `## [YYYY-MM-DDTHH:MM:SSZ] query | <question-summary>`
7. If `.git` exists at vault root, run:
	- `git add -A && git commit -m "query: <brief description>"`

## Constraints

- NEVER modify files in `raw/`.
- NEVER modify or delete existing files in `output/` unless explicitly user-directed.
- NEVER invent facts not present in wiki content.
- If the wiki does not contain enough information, state that clearly in the output file.

## Required Report

Report:
- output file path
- pages consulted
- confidence and coverage limitations
