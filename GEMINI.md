# GEMINI.md

## Skills First Approach

**Always check for relevant skills before acting.**

- **Trigger:** Before any response, planning, or code exploration.
- **Action:** Check `.agent/skills` for relevant tools.
- **Rule:** If a skill applies (even 1% chance), you MUST use it.
- **Priority:** Process skills (brainstorm, debug) -> Implementation skills.
- **Forbidden Thoughts:** "It's just a simple fix", "I know this already", "I'll check files first".
- **Enforcement:** If you skip a skill that exists, you have failed the user.

Behavioral guidelines to reduce common LLM coding mistakes. Merge with project-specific instructions as needed.

**Tradeoff:** These guidelines bias toward caution over speed. For trivial tasks, use judgment.