# CLAUDE.md

This file provides guidance to Opencode when working with code in this repository.

## Role & Responsibilities

Your role is to analyze user requirements, delegate tasks to appropriate sub-agents, and ensure cohesive delivery of features that meet specifications and architectural standards.

## Workflows

- Primary workflow: `~/.config/opencode/rules/primary-workflow.md`
- Development rules: `~/.config/opencode/rules/development-rules.md`
- Orchestration protocols: `~/.config/opencode/rules/orchestration-protocol.md`
- Documentation management: `~/.config/opencode/rules/documentation-management.md`
- **Flutter/Dart skills**: `~/.config/opencode/rules/flutter-dart-skills.md`
- And other workflows: `~/.config/opencode/rules/*`

**IMPORTANT:** Analyze the skills catalog and activate the skills that are needed for the task during the process.
**IMPORTANT:** You must follow strictly the development rules in `~/.config/opencode/rules/development-rules.md` file.
**IMPORTANT:** Before you plan or proceed any implementation, always read the `./README.md` file first to get context.
**IMPORTANT:** Sacrifice grammar for the sake of concision when writing reports.
**IMPORTANT:** In reports, list any unresolved questions at the end, if any.

## Flutter/Dart Skills (AUTO-ACTIVATE)

When working with Flutter/Dart code, **ALWAYS read** `~/.config/opencode/rules/flutter-dart-skills.md` first.

**P0 Critical Skills (read before ANY Flutter implementation):**
- `~/.config/opencode/skills/flutter/feature-based-clean-architecture/skill.md`
- `~/.config/opencode/skills/flutter/riverpod-state-management/skill.md`
- `~/.config/opencode/skills/flutter/go-router-navigation/skill.md`
- `~/.config/opencode/skills/dart/best-practices/skill.md`

## Python Scripts (Skills)

When running Python scripts from `~/.config/opencode/skills/`, use the venv Python interpreter:
- **Linux/macOS:** `~/.config/opencode/skills/.venv/bin/python3 scripts/xxx.py`
- **Windows:** `~\.config\.opencode\skills\.venv\Scripts\python.exe scripts\xxx.py`

This ensures packages installed by `install.sh` (google-genai, pypdf, etc.) are available.

**IMPORTANT:** When scripts of skills failed, don't stop, try to fix them directly.

## [IMPORTANT] Consider Modularization
- If a code file exceeds 200 lines of code, consider modularizing it
- Check existing modules before creating new
- Analyze logical separation boundaries (functions, classes, concerns)
- Use kebab-case naming with long descriptive names, it's fine if the file name is long because this ensures file names are self-documenting for LLM tools (Grep, Glob, Search)
- Write descriptive code comments
- After modularization, continue with main task
- When not to modularize: Markdown files, plain text files, bash scripts, configuration files, environment variables files, etc.

## Documentation Management

We keep all important docs in `./docs` folder and keep updating them, structure like below:

```
./docs
├── project-overview-pdr.md
├── code-standards.md
├── codebase-summary.md
├── design-guidelines.md
├── deployment-guide.md
├── system-architecture.md
└── project-roadmap.md
```

**IMPORTANT:** *MUST READ* and *MUST COMPLY* all *INSTRUCTIONS* in project `./AGENTS.md`, especially *WORKFLOWS* section is *CRITICALLY IMPORTANT*, this rule is *MANDATORY. NON-NEGOTIABLE. NO EXCEPTIONS. MUST REMEMBER AT ALL TIMES!!!*