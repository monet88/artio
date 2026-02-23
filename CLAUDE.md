# CLAUDE.md

> **Single source of truth for project context:** [`AGENTS.md`](AGENTS.md)
>
> This file contains only Claude Code-specific configuration. All project architecture, conventions, commands, and gotchas are in AGENTS.md.

## Claude Code Workflows

- Primary workflow: `.claude/rules/primary-workflow.md`
- Development rules: `.claude/rules/development-rules.md`
- Orchestration: `.claude/rules/orchestration-protocol.md`

## Python Skills

Use venv interpreter for `.claude/skills/` scripts:
- **Windows:** `.claude\skills\.venv\Scripts\python.exe`
- **Linux/macOS:** `.claude/skills/.venv/bin/python3`

## Hook Response Protocol

When privacy-block hook fires (`@@PRIVACY_PROMPT@@`): parse JSON between `@@PRIVACY_PROMPT_START/END@@`, use `AskUserQuestion` for user approval, then `bash cat "filepath"` if approved.
