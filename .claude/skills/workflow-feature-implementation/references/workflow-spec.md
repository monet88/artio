---
slug: "feature-implementation"
title: "Feature Implementation"
description: "End-to-end workflow for implementing Flutter features: scout codebase, plan, implement, UI/UX review, visual verify, test, code review, commit."

triggers:
  - "implement feature"
  - "build new feature"
  - "add feature"
  - "feature implementation workflow"
  - "full implementation pipeline"
  - "plan and implement"
  - "implement from scratch"
  - "new feature end to end"
  - "workflow implement"

artifact_store: "auto"
execution: "plan-then-confirm"

skills_sh_lookup: false
required_skills:
  - "scout"
  - "plan"
  - "cook"
  - "flutter-dart-best-practices"
  - "ui-ux-pro-max"
  - "ai-multimodal"
  - "test-driven-development"
  - "code-review"
  - "git"
optional_skills:
  - "debug"
  - "fix"
  - "research"
  - "supabase"
  - "sequential-thinking"

inputs:
  - name: "feature_description"
    kind: "string"
    required: true
    notes: "Natural language description of the feature to implement"
  - name: "repo_root"
    kind: "path"
    required: false
    notes: "Project root (default: CWD)"
  - name: "run_dir"
    kind: "path"
    required: false
    notes: "If provided, resume from existing run; otherwise resolve per artifact_store"

outputs:
  required:
    - "proposal.md"
    - "tasks.md"
    - "context.json"
  optional:
    - "evidence/"
---

# Workflow Spec: Feature Implementation

## Goal & Non-goals

### Goal

- Deliver a fully implemented, tested, reviewed, and committed Flutter feature following Clean Architecture patterns.
- Acceptance criteria:
  - Codebase scouted for context before planning
  - Implementation plan created with phases and TODO tasks
  - Feature implemented following Flutter/Dart best practices and project patterns
  - UI/UX reviewed for design quality (styles, accessibility, responsiveness)
  - UI visually verified via screenshot analysis
  - Tests written and passing (unit + widget minimum)
  - Code reviewed for quality, security, and maintainability
  - Changes committed with conventional commit messages

### Non-goals

- No deployment or CI/CD pipeline changes
- No database migrations unless explicitly part of the feature
- No refactoring of unrelated code
- No documentation updates beyond inline comments (use docs-manager separately)

### Constraints

- Stack: Flutter 3.10+, Dart 3.10+, Riverpod, GoRouter, Freezed, Supabase
- Architecture: Feature-first Clean Architecture (domain/data/presentation layers)
- Risk preference: Conservative — verify at each step before proceeding

## Skill Chain

### Step 0: Initialize run

- Purpose: create/resume `proposal.md`, `tasks.md`, `context.json`
- Notes: OpenSpec auto-detect; never rely on chat history for resume

### Step 1: Scout codebase

- Skill: `scout`
- Inputs: `repo_root`, feature description
- Output: codebase context summary (relevant files, patterns, dependencies)
- Outcome: understand where the feature fits in the existing architecture

### Step 2: Plan implementation

- Skill: `plan`
- Inputs: `repo_root`, feature description, scout output
- Output: plan directory under `plans/` with phases and TODO tasks
- Writes: `tasks.md` checklist + `## Approvals` placeholder
- Confirmation: ask user to confirm plan before execution

### Step 3: Implement feature

- Skill: `cook` + `flutter-dart-best-practices`
- Inputs: plan path, `repo_root`
- Output: implemented code changes
- Notes: follow plan phases sequentially, run `flutter analyze` after each file change
- Failure handling: if compile errors, fix immediately before proceeding

### Step 4: UI/UX review

- Skill: `ui-ux-pro-max`
- Inputs: changed UI files
- Output: `evidence/ui-ux-review.md`
- Notes: review accessibility, responsiveness, design patterns, Flutter-specific UI guidelines
- Failure handling: fix UI issues before proceeding

### Step 5: Visual verification

- Skill: `ai-multimodal`
- Inputs: app screenshots (run app and capture)
- Output: `evidence/visual-verification.md`
- Notes: use Gemini vision to verify UI renders correctly, matches design intent
- Confirmation: if visual issues found, ask user whether to fix or accept

### Step 6: Test

- Skill: `test-driven-development`
- Inputs: implemented feature files
- Output: test files + `evidence/test-results.md`
- Notes: write unit tests for domain/data, widget tests for presentation
- Failure handling: if tests fail, activate `fix` skill, then re-run tests (max 5 retries)

### Step 7: Code review

- Skill: `code-review`
- Inputs: all changed files
- Output: `evidence/code-review.md`
- Notes: review for YAGNI/KISS/DRY, security, Flutter patterns, architecture compliance
- Failure handling: fix review findings, then re-review

### Step 8: Commit

- Skill: `git`
- Inputs: staged changes
- Output: git commit(s) with conventional messages
- Notes: auto-split commits by type/scope if multiple concerns; run `flutter analyze` before commit
- Confirmation: show commit plan before executing

## Verification & Stop Rules

### Verification (minimum)

- `flutter analyze` passes with no errors
- `flutter test` passes with no failures
- UI/UX review score acceptable (no CRITICAL issues)
- Code review has no blocking findings
- Evidence files written under `evidence/` and indexed in `tasks.md`

### Stop rules (hard)

- If `flutter analyze` fails after 3 fix attempts: stop and run `debug` skill
- If tests fail after 5 fix attempts: stop, summarize failures, ask user
- If a required skill is missing: stop and suggest candidates, do not improvise
- If feature requires database changes not in scope: write approval item in `tasks.md` and wait

### Confirm-to-execute policy (required)

- Default: write plan first (Step 2), then ask user "Start execution?"
- If user confirms: begin execution and append approval record under `tasks.md -> ## Approvals` (timestamp + scope)
- Additional confirmation points: after UI/UX review (Step 5), before commit (Step 8)
