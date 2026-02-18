# Verification Process

### Step 0: Check for Previous Verification

Before starting fresh, check if a previous VERIFICATION.md exists:

```powershell
Get-ChildItem ".gsd/phases/{N}/*-VERIFICATION.md" -ErrorAction SilentlyContinue
```

**If previous verification exists with gaps → RE-VERIFICATION MODE:**
1. Parse previous VERIFICATION.md
2. Extract must-haves (truths, artifacts, key_links)
3. Extract gaps (items that failed)
4. Set `is_re_verification = true`
5. **Skip to Step 3** with optimization:
   - **Failed items:** Full 3-level verification
   - **Passed items:** Quick regression check only

**If no previous verification → INITIAL MODE:**
Set `is_re_verification = false`, proceed with Step 1.

---

### Step 1: Load Context (Initial Mode Only)

Gather verification context:

```powershell
# Phase PLANs and SUMMARYs
Get-ChildItem ".gsd/phases/{N}/*-PLAN.md"
Get-ChildItem ".gsd/phases/{N}/*-SUMMARY.md"

# Phase goal from ROADMAP
Select-String -Path ".gsd/ROADMAP.md" -Pattern "Phase {N}"
```

Extract phase goal from ROADMAP.md. This is the outcome to verify, not the tasks.

---

### Step 2: Establish Must-Haves (Initial Mode Only)

**Option A: Must-haves in PLAN frontmatter**

```yaml
must_haves:
  truths:
    - "User can see existing messages"
    - "User can send a message"
  artifacts:
    - path: "src/components/Chat.tsx"
      provides: "Message list rendering"
  key_links:
    - from: "Chat.tsx"
      to: "api/chat"
      via: "fetch in useEffect"
```

**Option B: Derive from phase goal**

1. **State the goal:** Take phase goal from ROADMAP.md
2. **Derive truths:** "What must be TRUE for this goal?"
   - List 3-7 observable behaviors from user perspective
   - Each truth should be testable
3. **Derive artifacts:** "What must EXIST?"
   - Map truths to concrete files
   - Be specific: `src/components/Chat.tsx`, not "chat component"
4. **Derive key links:** "What must be CONNECTED?"
   - Identify critical wiring (component → API → DB)
   - These are where stubs hide

---

### Step 3: Verify Observable Truths

For each truth, determine if codebase enables it.

**Verification status:**
- ✓ VERIFIED: All supporting artifacts pass all checks
- ✗ FAILED: Artifacts missing, stub, or unwired
- ? UNCERTAIN: Can't verify programmatically (needs human)

For each truth:
1. Identify supporting artifacts
2. Check artifact status (Step 4)
3. Check wiring status (Step 5)
4. Determine truth status

---

### Step 4: Verify Artifacts (Three Levels)

For each required artifact, verify three levels:

#### Level 1: Existence
```powershell
Test-Path "src/components/Chat.tsx"
```
- File exists at expected path
- **If missing:** FAILED at Level 1

#### Level 2: Substantive
```powershell
Get-Content "src/components/Chat.tsx" | Select-String -Pattern "TODO|placeholder|stub"
```
- File contains real implementation
- Not a stub, placeholder, or minimal scaffold
- **If stub detected:** FAILED at Level 2

#### Level 3: Wired
- Imports are used, not just present
- Exports are consumed by other files
- Functions are called with correct arguments
- **If unwired:** FAILED at Level 3

---

### Step 5: Verify Key Links (Wiring)

For each key link, verify the connection exists:

**Pattern: Component → API**
```powershell
# Check Chat.tsx calls /api/chat
Select-String -Path "src/components/Chat.tsx" -Pattern "fetch.*api/chat"
```

**Pattern: API → Database**
```powershell
# Check route calls prisma
Select-String -Path "src/app/api/chat/route.ts" -Pattern "prisma\."
```

**Pattern: Form → Handler**
```powershell
# Check onSubmit has implementation
Select-String -Path "src/components/Form.tsx" -Pattern "onSubmit" -Context 0,5
```

**Pattern: State → Render**
```powershell
# Check state is used in JSX
Select-String -Path "src/components/Chat.tsx" -Pattern "messages\.map"
```

---

### Step 6: Check Requirements Coverage

If REQUIREMENTS.md exists:

```powershell
Select-String -Path ".gsd/REQUIREMENTS.md" -Pattern "Phase {N}"
```

For each requirement:
1. Identify which truths/artifacts support it
2. Determine status based on supporting infrastructure

**Requirement status:**
- ✓ SATISFIED: All supporting truths verified
- ✗ BLOCKED: Supporting truths failed
- ? NEEDS HUMAN: Can't verify programmatically

---

### Step 7: Scan for Anti-Patterns

Run anti-pattern detection on modified files:

```powershell
# TODO/FIXME comments
Select-String -Path "src/**/*.ts" -Pattern "TODO|FIXME|XXX|HACK"

# Placeholder content
Select-String -Path "src/**/*.tsx" -Pattern "placeholder|coming soon" 

# Empty implementations
Select-String -Path "src/**/*.ts" -Pattern "return null|return \{\}|return \[\]"

# Console.log only
Select-String -Path "src/**/*.ts" -Pattern "console\.log" -Context 2
```

**Categorize findings:**
- 🛑 Blocker: Prevents goal achievement
- ⚠️ Warning: Indicates incomplete work
- ℹ️ Info: Notable but not problematic

---

### Step 8: Identify Human Verification Needs

Some things can't be verified programmatically:

**Always needs human:**
- Visual appearance (does it look right?)
- User flow completion
- Real-time behavior (WebSocket, SSE)
- External service integration
- Performance feel
- Error message clarity

**Format:**
```markdown
### 1. {Test Name}
**Test:** {What to do}
**Expected:** {What should happen}
**Why human:** {Why can't verify programmatically}
```

---

### Step 9: Determine Overall Status

**Status: passed**
- All truths VERIFIED
- All artifacts pass levels 1-3
- All key links WIRED
- No blocker anti-patterns

**Status: gaps_found**
- One or more truths FAILED
- OR artifacts MISSING/STUB
- OR key links NOT_WIRED
- OR blocker anti-patterns found

**Status: human_needed**
- All automated checks pass
- BUT items flagged for human verification

**Calculate score:**
```
score = verified_truths / total_truths
```

---

### Step 10: Structure Gap Output

When gaps found, structure for `/plan --gaps`:

```yaml
---
phase: {N}
verified: {timestamp}
status: gaps_found
score: {N}/{M} must-haves verified
gaps:
  - truth: "User can see existing messages"
    status: failed
    reason: "Chat.tsx doesn't fetch from API"
    artifacts:
      - path: "src/components/Chat.tsx"
        issue: "No useEffect with fetch call"
    missing:
      - "API call in useEffect to /api/chat"
      - "State for storing fetched messages"
      - "Render messages array in JSX"
---
```

---
