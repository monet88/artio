---
trigger: always_on
---

## Rule: neural-memory

## NeuralMemory — Persistent Memory

This workspace uses **NeuralMemory** MCP for persistent memory across sessions.
Use `nmem_*` tools **proactively** — do not wait for the user to ask.

### Session Start (ALWAYS do this)

```
nmem_recap()                             # Resume context from last session
nmem_context(limit=20, fresh_only=true)  # Load recent memories
nmem_session(action="get")               # Check current task/feature/progress
```

If `gap_detected: true`, run `nmem_auto(action="flush", text="<recent context>")` to recover lost content.

### During Work — REMEMBER automatically

| Event | Action |
|-------|--------|
| Decision made | `nmem_remember(content="...", type="decision", priority=7)` |
| Bug fixed | `nmem_remember(content="...", type="error", priority=7)` |
| User preference stated | `nmem_remember(content="...", type="preference", priority=6)` |
| Important fact learned | `nmem_remember(content="...", type="fact", priority=5)` |
| TODO identified | `nmem_todo(task="...", priority=6)` |
| Workflow discovered | `nmem_remember(content="...", type="workflow", priority=6)` |

### During Work — RECALL before asking

Before asking the user a question, check memory first:

```
nmem_recall(query="<topic>", depth=1)
```

Depth guide: 0=instant lookup, 1=context (default), 2=patterns, 3=deep graph traversal.

### Session End / Before Compaction

```
nmem_auto(action="process", text="<summary of session>")
nmem_session(action="set", feature="...", task="...", progress=0.8)
```

### Project Context

```
nmem_eternal(action="save", project_name="Artio", tech_stack=["Flutter", "Dart", "Riverpod", "Supabase"])
nmem_eternal(action="save", decision="...", reason="...")
```

### Codebase Indexing

First time on a project:
```
nmem_index(action="scan", path="./lib")
```

Then `nmem_recall(query="authentication")` finds related code through the neural graph.

### Rules

1. **Be proactive** — remember important info without being asked
2. **Check memory first** — recall before asking questions the user may have answered before
3. **Use types** — categorize memories correctly (fact/decision/error/preference/todo/workflow)
4. **Set priority** — critical=7-10, normal=5, trivial=1-3
5. **Add tags** — organize by project/topic for better retrieval
6. **Recap on start** — always call `nmem_recap()` at session beginning

### Memory Quality Skills

3 skills in `.agent/skills/` for NeuralMemory quality management:

| Skill | When to use | Trigger |
|-------|-------------|---------|
| **memory-audit** | Check brain health (6 dimensions: purity, freshness, coverage, clarity, relevance, structure) | User mentions "audit memory", "check memory health" |
| **memory-evolution** | Optimize memory: consolidate duplicates, prune dead, enrich gaps, normalize tags | User mentions "optimize memory", after audit |
| **memory-intake** | Convert raw info -> structured memories (1-question clarification, dedup, batch store) | User mentions "intake", "save notes", pastes large text to store |

**Recommended workflow:** intake -> audit (every 1-2 weeks) -> evolution (after audit)