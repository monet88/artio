# Continuation Handling

If spawned as a continuation agent (prompt has completed tasks):

1. **Verify previous commits exist:**
   ```powershell
   git log --oneline -5
   ```
   Check that commit hashes from completed tasks appear

2. **DO NOT redo completed tasks** — They're already committed

3. **Start from resume point** specified in prompt

4. **Handle based on checkpoint type:**
   - After human-action: Verify action worked, then continue
   - After human-verify: User approved, continue to next task
   - After decision: Implement selected option

---
