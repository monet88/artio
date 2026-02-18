---
description: Superpowers brainstorm. Produces goal/constraints/risks/options/recommendation/acceptance criteria.
---

# Superpowers Brainstorm

## Task
Brainstorm for this task (exactly as provided by the user):
**{{input}}**

If `{{input}}` is empty or missing, ask the user to restate the task in one sentence and STOP.

## Before you brainstorm
- Read relevant project context (`.gsd/ARCHITECTURE.md`, `.gsd/STACK.md`, KIs, memories) to ground the brainstorm in reality.
- Identify the feature area and skim related code if needed (use skills like `context-fetch` or `code-search`).
- Do NOT implement anything. This workflow produces a document, not code.

## Output sections (use exactly)

### Goal
State the desired outcome in 1–2 sentences. Be specific and measurable where possible.

### Constraints
List hard constraints (2–5 bullets): tech stack, budget, timeline, compatibility, performance, security requirements.

### Known context
Summarize what you already know from project docs, codebase, or previous conversations (3–6 bullets). Cite sources (file paths, KI names).

### Risks
Identify 2–4 risks. For each: one-line description + severity (High/Medium/Low) + mitigation idea.

| Risk | Severity | Mitigation |
|------|----------|------------|
| ... | High/Med/Low | ... |

### Options (2–4)
Present distinct approaches. For each option:
- **Name**: descriptive label
- **How**: 2–3 bullets on approach
- **Pros**: 1–2 bullets
- **Cons**: 1–2 bullets
- **Effort**: S/M/L estimate

### Recommendation
Pick one option and justify in 2–3 sentences. Reference specific pros/cons and constraints.

### Acceptance criteria
List 3–6 concrete, testable criteria. Each should be verifiable (e.g., "X test passes", "Y metric < Z", "user can do W").

## Persist (mandatory)
After generating the brainstorm, save it to disk:

**Target file:** `artifacts/superpowers/brainstorm.md`

Use `write_to_file` to write the brainstorm markdown directly. Create `artifacts/superpowers/` if it doesn't exist. After writing, confirm the file exists.

## Next step
After the brainstorm is saved, tell the user:
**"Brainstorm complete. Run `/superpowers-write-plan` to create an implementation plan."**

Do NOT implement changes in this workflow. Stop after persistence.