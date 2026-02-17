---
description: Superpowers brainstorm. Produces goal/constraints/risks/options/recommendation/acceptance criteria.
---

# Superpowers Brainstorm

## Task
Brainstorm for this task (exactly as provided by the user):
**{{input}}**

If `{{input}}` is empty or missing, ask the user to restate the task in one sentence and STOP.

## Output sections (use exactly)
## Goal
## Constraints
## Known context
## Risks
## Options (2–4)
## Recommendation
## Acceptance criteria

## Persist (mandatory)
After generating the brainstorm content, you MUST save it to disk:

**Target file:** `artifacts/superpowers/brainstorm.md`

**How to save (in priority order):**
1. **Preferred:** Use your file-writing tool (e.g. `write_to_file`) to write the brainstorm markdown directly to the target file. Create the `artifacts/superpowers/` directory if it doesn't exist.
2. **Fallback (CLI only):** If you cannot write files directly, run:
   ```bash
   echo '<brainstorm_content>' | python .agent/skills/superpowers-workflow/scripts/write_artifact.py --path artifacts/superpowers/brainstorm.md
   ```

**After writing:** Confirm the file exists by listing `artifacts/superpowers/`.

Do not implement changes in this workflow. Stop after persistence.