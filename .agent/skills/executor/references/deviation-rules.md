# Deviation Rules

**While executing tasks, you WILL discover work not in the plan.** This is normal.

Apply these rules automatically. Track all deviations for Summary documentation.

### RULE 1: Auto-fix Bugs

**Trigger:** Code doesn't work as intended

**Examples:**
- Wrong SQL query returning incorrect data
- Logic errors (inverted condition, off-by-one)
- Type errors, null pointer exceptions
- Broken validation
- Security vulnerabilities (SQL injection, XSS)
- Race conditions, deadlocks
- Memory leaks

**Process:**
1. Fix the bug inline
2. Add/update tests to prevent regression
3. Verify fix works
4. Continue task
5. Track: `[Rule 1 - Bug] {description}`

**No user permission needed.** Bugs must be fixed for correct operation.

---

### RULE 2: Auto-add Missing Critical Functionality

**Trigger:** Code is missing essential features for correctness, security, or basic operation

**Examples:**
- Missing error handling (no try/catch)
- No input validation
- Missing null/undefined checks
- No authentication on protected routes
- Missing authorization checks
- No CSRF protection
- No rate limiting on public APIs
- Missing database indexes

**Process:**
1. Add the missing functionality
2. Add tests for the new functionality
3. Verify it works
4. Continue task
5. Track: `[Rule 2 - Missing Critical] {description}`

**No user permission needed.** These are requirements for basic correctness.

---

### RULE 3: Auto-fix Blocking Issues

**Trigger:** Something prevents you from completing current task

**Examples:**
- Missing dependency
- Wrong types blocking compilation
- Broken import paths
- Missing environment variable
- Database connection config error
- Build configuration error
- Circular dependency

**Process:**
1. Fix the blocking issue
2. Verify task can now proceed
3. Continue task
4. Track: `[Rule 3 - Blocking] {description}`

**No user permission needed.** Can't complete task without fixing blocker.

---

### RULE 4: Ask About Architectural Changes

**Trigger:** Fix/addition requires significant structural modification

**Examples:**
- Adding new database table
- Major schema changes
- Introducing new service layer
- Switching libraries/frameworks
- Changing authentication approach
- Adding new infrastructure (queue, cache)
- Changing API contracts (breaking changes)

**Process:**
1. STOP current task
2. Return checkpoint with architectural decision
3. Include: what you found, proposed change, impact, alternatives
4. WAIT for user decision
5. Fresh agent continues with decision

**User decision required.** These changes affect system design.

---

### Rule Priority

1. **If Rule 4 applies** → STOP and return checkpoint
2. **If Rules 1-3 apply** → Fix automatically, track for Summary
3. **If unsure which rule** → Apply Rule 4 (return checkpoint)

**Edge case guidance:**
- "This validation is missing" → Rule 2 (security)
- "This crashes on null" → Rule 1 (bug)
- "Need to add table" → Rule 4 (architectural)
- "Need to add column" → Rule 1 or 2 (depends on context)

---
