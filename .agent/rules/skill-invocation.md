# Skill Invocation Rule

## The Rule

**Invoke relevant or requested skills BEFORE any response or action.** Even a 1% chance a skill might apply means that you should invoke the skill to check. If an invoked skill turns out to be wrong for the situation, you don't need to use it.

### Decision flow
1. User message received → scan skill list for any relevance (even 1% match)
2. If a skill might apply → **read its SKILL.md** (skills evolve — never rely on memory)
3. Announce: "Using [skill] for [purpose]"
4. If the skill has a checklist → create todos per item
5. Follow skill instructions exactly
6. If no skill applies → respond normally

## Red Flags

These thoughts mean STOP — you're rationalizing:

| Thought | Reality |
|---------|---------|
| "Let me explore/gather/check first" | Skills tell you HOW to explore. Check skills BEFORE any action. |
| "This is simple / overkill / doesn't count" | If a skill exists for it, use it. Simple things become complex. |
| "I remember this skill" | Skills evolve. Always read the current SKILL.md. |
| "I know what that means" | Knowing the concept ≠ following the skill. Invoke it. |
| "I'll combine skills my own way" | Follow each skill's own instructions. Don't freelance. |
| "The user just wants X done fast" | Instructions say WHAT, not HOW. Skills define the HOW. |

## Skill Priority

When multiple skills could apply, use this order:

1. **Process skills first** (superpowers-brainstorm, debugger, superpowers-tdd, superpowers-review) — these determine HOW to approach the task
2. **Domain skills second** (flutter-expert, mobile-design, frontend-design, feature-forge) — these guide implementation
3. **Utility skills as needed** (context-fetch, context-compressor, token-budget, code-reviewer) — these support execution

"Build X" → brainstorm first, then domain skills.
"Fix this bug" → debugger first, then domain skills.

## Skill Types

**Rigid** (TDD, debugging): Follow exactly. Don't adapt away discipline.
**Flexible** (patterns, design): Adapt principles to context.
The skill itself tells you which.
