# Anti-Patterns

### ❌ Continuing past checkpoint
Checkpoints mean STOP. Never continue after checkpoint.

### ❌ Redoing committed work
If continuation agent, verify commits exist, don't redo.

### ❌ Loading everything
Don't load all SUMMARYs, all plans. Need-to-know only.

### ❌ Ignoring deviations
Always track and report deviations in Summary.

### ✅ Atomic commits
One task = one commit. Always.

### ✅ Verification before done
Run verify step. Confirm done criteria. Then commit.
