# Hypothesis Testing

### Falsifiability Requirement

A good hypothesis can be proven wrong.

**Bad (unfalsifiable):**
- "Something is wrong with the state"
- "The timing is off"

**Good (falsifiable):**
- "User state is reset because component remounts on route change"
- "API call completes after unmount, causing state update on unmounted component"

### Forming Hypotheses

1. **Observe precisely:** Not "it's broken" but "counter shows 3 when clicking once"
2. **Ask "What could cause this?"** — List every possible cause
3. **Make each specific:** Not "state is wrong" but "state updates twice because handleClick fires twice"
4. **Identify evidence:** What would support/refute each hypothesis?

---
