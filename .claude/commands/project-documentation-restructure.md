---
name: project-documentation-restructure
description: Workflow command scaffold for project-documentation-restructure in artio.
allowed_tools: ["Bash", "Read", "Write", "Grep", "Glob"]
---

# /project-documentation-restructure

Use this workflow when working on **project-documentation-restructure** in `artio`.

## Goal

Reorganizes, initializes, or updates project documentation, including architecture, decision logs, templates, and removing obsolete files/scripts.

## Common Files

- `docs/ARCHITECTURE.md`
- `docs/README.md`
- `docs/decisions/README.md`
- `docs/templates/*.md`
- `docs/project-changelog.md`
- `docs/project-roadmap.md`

## Suggested Sequence

1. Understand the current state and failure mode before editing.
2. Make the smallest coherent change that satisfies the workflow goal.
3. Run the most relevant verification for touched files.
4. Summarize what changed and what still needs review.

## Typical Commit Signals

- Create or update multiple markdown documentation files under docs/ (e.g., ARCHITECTURE.md, README.md, decision logs, templates).
- Add or update scripts in scripts/ to support documentation validation or search.
- Remove obsolete documentation or script files.
- Update .gitignore if new documentation/script artifacts are generated.

## Notes

- Treat this as a scaffold, not a hard-coded script.
- Update the command if the workflow evolves materially.