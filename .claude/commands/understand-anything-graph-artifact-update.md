---
name: understand-anything-graph-artifact-update
description: Workflow command scaffold for understand-anything-graph-artifact-update in artio.
allowed_tools: ["Bash", "Read", "Write", "Grep", "Glob"]
---

# /understand-anything-graph-artifact-update

Use this workflow when working on **understand-anything-graph-artifact-update** in `artio`.

## Goal

Adds or updates knowledge graph artifacts and intermediate analysis outputs for the 'Understand Anything' tool.

## Common Files

- `.understand-anything/intermediate/*.json`
- `.understand-anything/knowledge-graph.json`
- `.understand-anything/meta.json`
- `.understand-anything/.understandignore`

## Suggested Sequence

1. Understand the current state and failure mode before editing.
2. Make the smallest coherent change that satisfies the workflow goal.
3. Run the most relevant verification for touched files.
4. Summarize what changed and what still needs review.

## Typical Commit Signals

- Add or update .understand-anything/intermediate/*.json files (batches, graphs, reviews, etc.).
- Update .understand-anything/knowledge-graph.json and meta.json.
- Update .understand-anything/.understandignore to ignore new or obsolete artifacts.

## Notes

- Treat this as a scaffold, not a hard-coded script.
- Update the command if the workflow evolves materially.