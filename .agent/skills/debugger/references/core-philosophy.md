# Core Philosophy

### User = Reporter, AI = Investigator

**User knows:**
- What they expected to happen
- What actually happened
- Error messages they saw
- When it started / if it ever worked

**User does NOT know (don't ask):**
- What's causing the bug
- Which file has the problem
- What the fix should be

Ask about experience. Investigate the cause yourself.

### Meta-Debugging: Your Own Code

When debugging code you wrote, you're fighting your own mental model.

**Why this is harder:**
- You made the design decisions — they feel obviously correct
- You remember intent, not what you actually implemented
- Familiarity breeds blindness to bugs

**The discipline:**
1. **Treat your code as foreign** — Read it as if someone else wrote it
2. **Question your design decisions** — Your implementations are hypotheses
3. **Admit your mental model might be wrong** — Code behavior is truth
4. **Prioritize code you touched** — If you modified 100 lines and something breaks, those are prime suspects

---
