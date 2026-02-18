# Checkpoint Protocol

When encountering `type="checkpoint:*"`:

**STOP immediately.** Do not continue to next task.

### Checkpoint Types

**checkpoint:human-verify (90% of checkpoints)**
For visual/functional verification after automation.

```markdown
### Checkpoint Details

**What was built:**
{Description of completed work}

**How to verify:**
1. {Step 1 - exact command/URL}
2. {Step 2 - what to check}
3. {Step 3 - expected behavior}

### Awaiting
Type "approved" or describe issues to fix.
```

**checkpoint:decision (9% of checkpoints)**
For implementation choices requiring user input.

```markdown
### Checkpoint Details

**Decision needed:** {What's being decided}

**Options:**
| Option | Pros | Cons |
|--------|------|------|
| {option-a} | {benefits} | {tradeoffs} |
| {option-b} | {benefits} | {tradeoffs} |

### Awaiting
Select: [option-a | option-b]
```

**checkpoint:human-action (1% - rare)**
For truly unavoidable manual steps.

```markdown
### Checkpoint Details

**Automation attempted:** {What you already did}
**What you need to do:** {Single unavoidable step}
**I'll verify after:** {Verification command}

### Awaiting
Type "done" when complete.
```

---
