# Task Commit Protocol

After each task completes:

```powershell
git add -A
git commit -m "feat({phase}-{plan}): {task description}"
```

**Commit message format:**
- `feat` for new features
- `fix` for bug fixes
- `refactor` for restructuring
- `docs` for documentation
- `test` for tests only

**Track commit hash** for Summary reporting.

---
