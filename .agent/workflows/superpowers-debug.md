---
description: Systematic debugging workflow: reproduce, minimize, hypotheses, instrument, fix, prevent, verify.
---

# Superpowers Debug

Read and apply the `superpowers-debug` skill.

Use the required reporting format:
- Symptom
- Repro steps
- Root cause
- Fix
- Regression protection
- Verification

## Persist (mandatory)
After generating the debug content, you MUST save it to disk:

**Target file:** `artifacts/superpowers/debug.md`

**How to save (in priority order):**
1. **Preferred:** Use your file-writing tool (e.g. `write_to_file`) to write the debug markdown directly to the target file. Create the `artifacts/superpowers/` directory if it doesn't exist.
2. **Fallback (CLI only):** If you cannot write files directly, run:
   ```bash
   echo '<debug_content>' | python .agent/skills/superpowers-workflow/scripts/write_artifact.py --path artifacts/superpowers/debug.md
   ```

**After writing:** Confirm the file exists by listing `artifacts/superpowers/`.

Do not implement changes in this workflow. Stop after persistence.
