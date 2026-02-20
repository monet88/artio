## Project Context

**Artio** — AI art generation app (Flutter/Dart). Monorepo: mobile app (`lib/`) + admin dashboard (`admin/`).

- **Stack:** Flutter 3 · Riverpod (codegen) · GoRouter · Supabase (Auth/DB/Storage/Edge Functions) · Freezed · Sentry
- **Architecture:** Clean Architecture per feature (`data/domain/presentation`), 7 features: auth, template_engine, create, gallery, settings, credits, subscription
- **AI Providers:** KIE.ai + Google Gemini via Supabase Edge Function (`supabase/functions/generate-image/`)
- **Docs:** `.gsd/ARCHITECTURE.md` · `.gsd/STACK.md` · `docs/` (project docs, code standards, system architecture)

> **Always read existing context first** — `.gsd/ARCHITECTURE.md`, `.gsd/STACK.md`, KIs, memories — before analyzing source code or doing independent research. Don't re-discover what's already documented.

---

## Code Search & Navigation

**Semantic search** via `mcp__ck-search__semantic_search` for concept-based discovery:
- "Where does X happen?" → `semantic_search` (finds by meaning, not keywords)
- "Find all uses of pattern Y" → `Grep` or `lexical_search` (exact match)
- Use `semantic_search` with `top_k: 5-10`, `snippet_length: 300` for best results.
- Index: `.ck/` directory (223 code files, model `bge-small`). Reindex after major changes via MCP `reindex` tool.

**Serena MCP** symbolic code navigation configured (`.serena/project.yml`):
- Prefer Serena tools over Read/Edit/Grep for code navigation and editing
- Source directories: `lib/`, `test/`
- Full best practices: `.agent/skills/code-search/SKILL.md`

---

## Development Rules

**Principles:** YAGNI · KISS · DRY — always.

Detailed rules in `.agent/rules/`:
- **`coding-style.md`** — Immutability, file org (≤250 lines), error handling, quality checklist
- **`security.md`** — Pre-commit security checks, secret management
- **`git-workflow.md`** — Conventional commits, PR workflow, pre-push requirements, GitHub MCP priority
- **`testing.md`** — TDD (red/green/refactor), 80%+ coverage, mocktail
- **`patterns.md`** — Repository pattern, Freezed entities, Riverpod state, error handling flow

### Dart MCP vs Shell

**Dart MCP is the default** for analyze, test, fix, format, and pub. Only use shell when you need pipe/filter output or flags that MCP doesn't expose.

| Scenario | Use | Reason |
|----------|-----|--------|
| Analyze, test, fix, format (standard) | **Dart MCP** | Structured output, less noise |
| Need pipe/filter output (grep, select-string) | **Shell** | MCP doesn't support piping |
| Need special flags (`--reporter`, `--name`) | **Shell** | MCP doesn't expose all flags |
| Pub commands (add, get, deps, outdated) | **Dart MCP** | `pub` tool has full support |

---

## GSD Methodology

> Canonical rules: [PROJECT_RULES.md](PROJECT_RULES.md)

**Core Principles:**
1. **Plan Before You Build** — No code without specification
2. **State Is Sacred** — Every action updates persistent memory
3. **Context Is Limited** — Prevent degradation through hygiene
4. **Verify Empirically** — No "trust me, it works"

**Quick Reference:**
```
Before coding    → Check SPEC.md is FINALIZED
Before file read → Search first, then targeted read
After each task  → Update STATE.md
After 3 failures → State dump + fresh session
Before "Done"    → Empirical proof captured
```

**Workflow Integration:**

| Workflow | Rules Enforced |
|----------|----------------|
| `/map` | Updates ARCHITECTURE.md, STACK.md |
| `/plan` | Enforces Planning Lock, creates ROADMAP |
| `/execute` | Enforces State Persistence after each task |
| `/verify` | Enforces Empirical Validation |
| `/pause` | Triggers Context Hygiene state dump |
| `/resume` | Loads state from STATE.md |

---

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
| **memory-intake** | Convert raw info → structured memories (1-question clarification, dedup, batch store) | User mentions "intake", "save notes", pastes large text to store |

**Recommended workflow:** intake → audit (every 1-2 weeks) → evolution (after audit)