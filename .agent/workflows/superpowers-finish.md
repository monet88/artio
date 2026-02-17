---
description: Finalize work: verification, summary, follow-ups, manual validation steps.
---

# Superpowers Finish

Read and apply the `superpowers-finish` skill.

Output:
## Verification (commands + results if possible)
## Summary of changes
## Follow-ups (if needed)
## Manual validation steps (if applicable)

## Persist (mandatory)
After generating the finish content, you MUST save it to disk:

**Target file:** `artifacts/superpowers/finish.md`

**How to save (in priority order):**
1. **Preferred:** Use your file-writing tool (e.g. `write_to_file`) to write the finish markdown directly to the target file. Create the `artifacts/superpowers/` directory if it doesn't exist.
2. **Fallback (CLI only):** If you cannot write files directly, run:
   ```bash
   echo '<finish_content>' | python .agent/skills/superpowers-workflow/scripts/write_artifact.py --path artifacts/superpowers/finish.md
   ```

**After writing:** Confirm the file exists by listing `artifacts/superpowers/`.

Do not implement changes in this workflow. Stop after persistence.
