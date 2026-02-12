---
name: workflow-feature-implementation
description: "End-to-end Flutter feature implementation workflow: scout, plan, implement, UI/UX review, visual verify, test, code review, commit. Use when: implement feature, build new feature, add feature, full implementation pipeline, plan and implement, implement from scratch, new feature end to end, workflow implement."
---

# Workflow: Feature Implementation (Plan -> Confirm -> Execute)

End-to-end pipeline for implementing Flutter features with quality gates at each step.

## Core Principles

- **YAGNI, KISS, DRY** always.
- Pass paths only (never paste large content into chat).
- Artifact-first and resumable: `proposal.md`, `tasks.md`, `context.json` are the resume surface.
- Confirmation points: plan first; for high-risk actions, record approval in `tasks.md`.

## Inputs

- `feature_description` (required): natural language description of the feature
- `repo_root` (optional): project root, default CWD
- `run_dir` (optional): resume from existing run

## Outputs (written under `run_dir/`)

- Required: `proposal.md`, `tasks.md`, `context.json`
- Optional: `evidence/`

## Spec (SSOT)

Read first: `references/workflow-spec.md`

## Run Directory Backend

Resolve `run_dir` deterministically:

1. If `context.json` sets `artifact_store: runs|openspec`, follow it.
2. Else if `openspec/project.md` exists under `repo_root`, use `openspec/changes/<change-id>/`.
3. Else use `plans/<date>-<slug>/` (project convention).

## Required Skills

| Step | Skill | Purpose |
|------|-------|---------|
| 1 | `scout` | Quick codebase scan for context |
| 2 | `plan` | Create implementation plan with phases |
| 3 | `cook` + `flutter-dart-best-practices` | Implement feature |
| 4 | `ui-ux-pro-max` | Review UI/UX design quality |
| 5 | `ai-multimodal` | Visual verification via screenshots |
| 6 | `test-driven-development` | Write and run tests |
| 7 | `code-review` | Review code quality and security |
| 8 | `git` | Commit with conventional messages |

Optional fallbacks: `debug`, `fix`, `research`, `supabase`, `sequential-thinking`

If a required skill is missing locally: stop and suggest candidates, do not improvise.

## Process

### 0) Initialize run (required)

- Create/resume `proposal.md`, `tasks.md`, `context.json`.
- In `tasks.md`, ensure sections exist:
  - `## Checklist`
  - `## Verification`
  - `## Approvals`
  - `## Evidence Index`

### 1) Scout codebase

- Activate skill: `scout`
- Scan repo for relevant files, patterns, dependencies related to the feature.
- Write findings to `context.json` for downstream steps.

### 2) Plan implementation

- Activate skill: `plan`
- Create plan directory under `plans/` with phases and TODO tasks.
- Populate `proposal.md` with feature summary and approach.
- Write executable checklist to `tasks.md`.
- **CONFIRM**: Ask user "Plan ready. Start execution?" before proceeding.
- On confirmation: append approval record to `tasks.md -> ## Approvals` (timestamp + scope).

### 3) Implement feature

- Activate skills: `cook`, `flutter-dart-best-practices`
- Follow plan phases sequentially.
- Run `flutter analyze` after each file change — fix errors immediately.
- Architecture: Feature-first Clean Architecture (domain/data/presentation).
- State: Riverpod with `@riverpod` code generation only.

### 4) UI/UX review

- Activate skill: `ui-ux-pro-max`
- Review changed UI files for: accessibility, responsiveness, design patterns, Flutter guidelines.
- Write findings to `evidence/ui-ux-review.md`.
- Fix any CRITICAL issues before proceeding.

### 5) Visual verification

- Activate skill: `ai-multimodal`
- Capture app screenshots and analyze with Gemini vision.
- Write findings to `evidence/visual-verification.md`.
- **CONFIRM**: If visual issues found, ask user whether to fix or accept.

### 6) Test

- Activate skill: `test-driven-development`
- Write unit tests (domain/data) + widget tests (presentation).
- Run `flutter test` and record results.
- Write to `evidence/test-results.md`.
- On failure: activate `fix` skill, retry (max 5 attempts).
- On 5th failure: stop, summarize, ask user.

### 7) Code review

- Activate skill: `code-review`
- Review all changed files for: YAGNI/KISS/DRY, security, Flutter patterns, architecture.
- Write to `evidence/code-review.md`.
- Fix blocking findings, then re-review.

### 8) Commit

- Activate skill: `git`
- Run `flutter analyze` one final time.
- Auto-split commits by type/scope if multiple concerns.
- **CONFIRM**: Show commit plan before executing.
- Use conventional commit format: `feat:`, `fix:`, `refactor:`, etc.

### 9) Stop rules (hard)

- `flutter analyze` fails after 3 fix attempts: stop, run `debug`.
- Tests fail after 5 fix attempts: stop, summarize, ask user.
- Required skill missing: stop, suggest candidates.
- Out-of-scope DB changes needed: write approval item in `tasks.md`, wait.
