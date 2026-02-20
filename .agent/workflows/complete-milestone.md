---
description: Mark current milestone as complete and archive
---

# /complete-milestone Workflow

<objective>
Finalize the current milestone, archive documentation, and prepare for next milestone.
</objective>

<process>

## 1. Verify All Phases Complete

**PowerShell:**
```powershell
# Check ROADMAP.md for incomplete phases
Select-String -Path ".gsd/ROADMAP.md" -Pattern "Status.*Not Started|Status.*In Progress"
```

**Bash:**
```bash
# Check ROADMAP.md for incomplete phases
grep -E "Status.*Not Started|Status.*In Progress" ".gsd/ROADMAP.md"
```

**If incomplete phases found:**
```
⚠️ Cannot complete milestone — {N} phases incomplete

Run /progress to see status.
```

---

## 2. Run Final Verification

Verify all must-haves from ROADMAP.md:
- Run verification commands
- Capture evidence
- Create VERIFICATION.md if not exists

---

## 3. Generate Milestone Summary

Create `.gsd/milestones/{name}-SUMMARY.md`:

```markdown
# Milestone: {name}

## Completed: {date}

## Deliverables
- ✅ {must-have 1}
- ✅ {must-have 2}

## Phases Completed
1. Phase 1: {name} — {date}
2. Phase 2: {name} — {date}
...

## Metrics
- Total commits: {N}
- Files changed: {M}
- Duration: {days}

## Lessons Learned
{Auto-extract from DECISIONS.md and JOURNAL.md}
```

---

## 4. Archive Current State

> **IMPORTANT:** Use `Move-Item` / `mv` (NOT `Copy-Item` / `cp`).
> Moving deletes the originals automatically — NO separate cleanup step needed.

// turbo
**PowerShell:**
```powershell
# Create milestone archive
New-Item -ItemType Directory -Force ".gsd/milestones/{name}"

# Move phase files (plans, summaries, verifications)
Move-Item ".gsd/phases/*" ".gsd/milestones/{name}/"

# Move AUDIT.md if present
if (Test-Path ".gsd/AUDIT.md") { Move-Item ".gsd/AUDIT.md" ".gsd/milestones/{name}/" }
```

// turbo
**Bash:**
```bash
# Create milestone archive
mkdir -p ".gsd/milestones/{name}"

# Move phase files (plans, summaries, verifications)
mv .gsd/phases/* ".gsd/milestones/{name}/"

# Move AUDIT.md if present
[ -f ".gsd/AUDIT.md" ] && mv ".gsd/AUDIT.md" ".gsd/milestones/{name}/"
```

After this step, `.gsd/phases/` should be **empty** and ready for the next milestone.

---

## 5. Reset for Next Milestone

Clear ROADMAP.md phases section (keep header).
Update STATE.md to show milestone complete.

---

## 6. Commit and Tag

```bash
git add -A
git commit -m "docs: complete milestone {name}"
git tag -a "{name}" -m "Milestone {name} complete"
```

---

## 7. Celebrate

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 GSD ► MILESTONE COMPLETE 🎉
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

{name}

Phases: {N} completed
Tag: {name}

───────────────────────────────────────────────────────

▶ NEXT

/new-milestone — Start next milestone
/audit-milestone {name} — Review this milestone

───────────────────────────────────────────────────────
```

</process>
