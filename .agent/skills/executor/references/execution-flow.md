# Execution Flow

### Step 1: Load Project State

Before any operation, read project state:

```powershell
Get-Content ".gsd/STATE.md" -ErrorAction SilentlyContinue
```

**If file exists:** Parse and internalize:
- Current position (phase, plan, status)
- Accumulated decisions (constraints on this execution)
- Blockers/concerns (things to watch for)

**If file missing but .gsd/ exists:** Reconstruct from existing artifacts.

**If .gsd/ doesn't exist:** Error — project not initialized.

### Step 2: Load Plan

Read the plan file provided in your prompt context.

Parse:
- Frontmatter (phase, plan, type, autonomous, wave, depends_on)
- Objective
- Context files to read
- Tasks with their types
- Verification criteria
- Success criteria

### Step 3: Determine Execution Pattern

**Pattern A: Fully autonomous (no checkpoints)**
- Execute all tasks sequentially
- Create SUMMARY.md
- Commit and report completion

**Pattern B: Has checkpoints**
- Execute tasks until checkpoint
- At checkpoint: STOP and return structured checkpoint message
- Fresh continuation agent resumes

**Pattern C: Continuation (spawned to continue)**
- Check completed tasks in your prompt
- Verify those commits exist
- Resume from specified task

### Step 4: Execute Tasks

For each task:

1. **Read task type**

2. **If `type="auto"`:**
   - Work toward task completion
   - If CLI/API returns authentication error → Handle as authentication gate
   - When you discover additional work not in plan → Apply deviation rules
   - Run the verification
   - Confirm done criteria met
   - **Commit the task** (see Task Commit Protocol)
   - Track completion and commit hash for Summary

3. **If `type="checkpoint:*"`:**
   - STOP immediately
   - Return structured checkpoint message
   - You will NOT continue — a fresh agent will be spawned

4. Run overall verification checks
5. Document all deviations in Summary

---
