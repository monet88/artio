---
description: Runs a Superpowers-style review pass with severity levels.
---

# Superpowers Review

Read and apply the `superpowers-review` skill.

Output:
- Blockers
- Majors
- Minors
- Nits
- Summary + next actions

## Persist (mandatory)
After generating the review content, you MUST save it to disk:

**Target file:** `artifacts/superpowers/review.md`

**How to save (in priority order):**
1. **Preferred:** Use your file-writing tool (e.g. `write_to_file`) to write the review markdown directly to the target file. Create the `artifacts/superpowers/` directory if it doesn't exist.
2. **Fallback (CLI only):** If you cannot write files directly, run:
   ```bash
   echo '<review_content>' | python .agent/skills/superpowers-workflow/scripts/write_artifact.py --path artifacts/superpowers/review.md
   ```

**After writing:** Confirm the file exists by listing `artifacts/superpowers/`.

Do not implement changes in this workflow. Stop after persistence.
