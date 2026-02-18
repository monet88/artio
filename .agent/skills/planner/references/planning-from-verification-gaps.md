# Planning from Verification Gaps

When `/verify` finds gaps, create targeted fix plans:

1. **Load gap report** from VERIFICATION.md
2. **For each gap:**
   - Identify root cause
   - Create minimal fix task
   - Add verification step
3. **Mark as gap closure:**
   ```yaml
   gap_closure: true
   ```

Gap closure plans:
- Execute with `/execute {N} --gaps-only`
- Smaller scope than normal plans
- Focus on single issue per plan

---
