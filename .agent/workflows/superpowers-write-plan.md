---
description: Superpowers plan gate. Writes a small-step plan with files + verification. Must ask for approval before coding.
---

# Superpowers Write Plan (Gate)

## Task
Plan for this task (exactly as provided by the user):
**{{input}}**

If `{{input}}` is empty or missing, ask the user to restate the task in one sentence and STOP.

## Rules
- DO NOT edit code.
- You may read files to understand context, but produce the plan and then stop.
- Plan steps must be small (2–10 minutes each) and include verification commands.

## Output format (use exactly)
## Goal
## Assumptions
## Plan
(Each step must include: Files, Change, Verify)
## Risks & mitigations
## Rollback plan

## Persist (mandatory)
After generating the plan content, you MUST save it to disk:

**Target file:** `artifacts/superpowers/plan.md`

**How to save (in priority order):**
1. **Preferred:** Use your file-writing tool (e.g. `write_to_file`) to write the plan markdown directly to the target file. Create the `artifacts/superpowers/` directory if it doesn't exist.
2. **Fallback (CLI only):** If you cannot write files directly, run:
   ```bash
   echo '<plan_content>' | python .agent/skills/superpowers-workflow/scripts/write_artifact.py --path artifacts/superpowers/plan.md
   ```

**After writing:** Confirm the file exists by listing `artifacts/superpowers/`.

## Approval
Ask:
**Approve this plan? Reply APPROVED if it looks good.**

If the user replies APPROVED:
- Do NOT implement yet.
- Reply: **"Plan approved. Run `/superpowers-execute-plan` to begin implementation."**

Do not implement changes in this workflow. Stop after persistence.
