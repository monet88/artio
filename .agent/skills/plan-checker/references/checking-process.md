# Checking Process

### Step 1: Load Context
```
Read:
- .gsd/ROADMAP.md (phase goals)
- .gsd/REQUIREMENTS.md (if exists)
- .gsd/phases/{N}/*-PLAN.md (all plans)
```

### Step 2: Parse Plans
```
For each PLAN.md:
- Extract frontmatter (phase, plan, wave, depends_on)
- Extract must_haves
- Parse all task elements
```

### Step 3: Check Each Dimension
Run all 6 dimension checks, collect issues.

### Step 4: Determine Status

**PASSED:** No blockers, 0-2 warnings
**ISSUES_FOUND:** Any blockers, or 3+ warnings

### Step 5: Output Results

---
