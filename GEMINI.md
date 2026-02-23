## Project Context

**Artio** — AI art generation app (Flutter/Dart). Monorepo: mobile app (`lib/`) + admin dashboard (`admin/`).

- **Stack:** Flutter 3 · Riverpod (codegen) · GoRouter · Supabase (Auth/DB/Storage/Edge Functions) · Freezed · Sentry
- **Architecture:** Clean Architecture per feature (`data/domain/presentation`), 7 features: auth, template_engine, create, gallery, settings, credits, subscription
- **AI Providers:** KIE.ai + Google Gemini via Supabase Edge Function (`supabase/functions/generate-image/`)
- **Docs:** `docs/code-standards.md` (649-line canonical reference), `docs/` (project docs, system architecture)

> **Always read existing context first** — `docs/code-standards.md`, KIs, memories — before analyzing source code. Don't re-discover what's already documented.

---

## Phase 0 — Intent Gate (EVERY message)

Before acting, classify the request and fire relevant triggers.

### Key Triggers (check BEFORE classification)

- External library/package mentioned → fire `docs-seeker` skill (context7)
- 2+ modules involved → fire `scout` skill (parallel agents)
- GitHub mention / "create PR" → Full cycle: investigate → implement → PR
- "Look into" + "create PR" → Not just research. Full implementation expected.
- User pastes error/stack trace → fire `debug` skill + `debugger` agent

### Skill Triggers (fire IMMEDIATELY when matched)

| Trigger | Skill | Notes |
|---------|-------|-------|
| Implementing ANY feature/code | `cook` | **ALWAYS** before implementation |
| Fixing ANY bug/error/test failure | `fix` | **ALWAYS** before fixing |
| Debugging, investigating issues | `debug` | + `debugger` agent |
| Codebase discovery, "find X", "where is Y" | `scout` | Parallel file discovery |
| Research, "how to do X", best practices | `research` | + `researcher` agent |
| Brainstorming, "should we X?", trade-offs | `brainstorm` | + `brainstormer` agent |
| Planning multi-step task | `plan` | + `planner` agent |
| Code review, before PR | `code-review` | + `code-reviewer` agent |
| UI/UX design work | `ui-ux-pro-max` | + `ui-ux-designer` agent |
| Flutter/Dart mobile patterns | `mobile-development` | |
| Database/Supabase/PostgreSQL | `databases` | `psql` for debugging |
| Complex multi-step reasoning | `sequential-thinking` | |
| Stuck after multiple failures | `problem-solving` | |
| Git commit/PR/branch | `git` | + `git-manager` agent |
| Multi-agent parallel work | `team` | Orchestration |
| MCP tool questions/issues | `mcp-management` | + `mcp-manager` agent |
| Image/video/doc analysis | `ai-multimodal` | |
| Architecture diagrams | `mermaidjs-v11` | |
| External docs/library lookup | `docs-seeker` | context7 MCP |
| Context usage/optimization | `context-engineering` | |

### Workflow Triggers (slash commands)

| Trigger | Workflow | Notes |
|---------|----------|-------|
| Quick technical question | `/ask` | Direct answer |
| Review entire codebase | `/review-codebase` | or `/review-codebase-parallel` |
| PR review (full pipeline) | `/prr master` | Select → Describe → Review → Report |
| Quick PR review | `/prr /quick` | One-command pipeline |
| Initialize project docs | `/docs-init` | |
| Update existing docs | `/docs-update` | + `docs-manager` agent |
| Run tests + analyze | `/test` | + `tester` agent |
| Validate plan | `/plan-validate` | Critical questions interview |
| View plan progress | `/kanban` | Plans dashboard |
| Session wrap-up | `/watzup` | Review recent changes |
| Journal entry | `/journal` | + `journal-writer` agent |
| Visual preview/diagrams | `/preview` | |

### Classify Request Type

| Type | Signal | Action |
|------|--------|--------|
| **Trivial** | Single file, known location, direct answer | Direct tools only |
| **Explicit** | Specific file/line, clear command | Execute directly |
| **Exploratory** | "How does X work?", "Find Y" | `scout` + `research` in parallel |
| **Open-ended** | "Improve", "Refactor", "Add feature" | `cook` → `plan` → implement |
| **Ambiguous** | Unclear scope, multiple interpretations | Ask ONE clarifying question |

### Check for Ambiguity

| Situation | Action |
|-----------|--------|
| Single valid interpretation | Proceed |
| Multiple interpretations, similar effort | Proceed with reasonable default, note assumption |
| Multiple interpretations, 2x+ effort difference | **MUST ask** |
| User's design seems suboptimal | **MUST raise concern** before implementing |

---

## Phase 1 — Research & Discovery

### Tool Selection

| Tool | Cost | When |
|------|------|------|
| Direct tools (grep, view_file, Serena) | FREE | Scope clear, no implicit assumptions |
| `scout` skill | FREE | Multiple search angles, unfamiliar modules |
| `researcher` agent | CHEAP | Best practices, external patterns |
| `docs-seeker` skill | CHEAP | External library/framework docs |
| `brainstormer` agent | MODERATE | Architecture decisions, trade-off analysis |
| `sequential-thinking` skill | MODERATE | Complex multi-step reasoning |

**Default flow**: `scout` + `researcher` (parallel background) → collect results → proceed.

### Parallel Execution (DEFAULT)

```
scout(prompt="Find auth implementations...")        # background
scout(prompt="Find error handling patterns...")      # background
researcher(prompt="Best practices for Flutter X")   # background
docs-seeker(topic="riverpod codegen patterns")      # background
# Continue working immediately. Collect when needed.
```

### Search Stop Conditions

STOP when: enough context to proceed, same info appearing across sources, or 2 iterations yielded no new data. **Do NOT over-explore.**

---

## Phase 2 — Implementation

### Pre-Implementation (NON-NEGOTIABLE)

1. Fire `cook` skill **ALWAYS**
2. If task has 2+ steps → create todo/plan IMMEDIATELY
3. Mark current task `in_progress` before starting
4. Mark `completed` as soon as done (never batch)

### Agent Delegation Table

| Domain | Agent | When |
|--------|-------|------|
| Planning | `planner` | Multi-step tasks, implementation plans |
| Research | `researcher` | Technical deep-dives, best practices |
| Brainstorming | `brainstormer` | Solution exploration, trade-offs |
| Implementation | `fullstack-developer` | Code implementation |
| Testing | `tester` | Write/run tests, analyze failures |
| Code Review | `code-reviewer` | After implementation, before PR |
| Simplification | `code-simplifier` | Reduce complexity after review |
| Debugging | `debugger` | Bug investigation, root cause |
| Documentation | `docs-manager` | Update docs after changes |
| Git | `git-manager` | Commits, PRs, branches |
| Project Tracking | `project-manager` | Update roadmap, changelog |
| UI/UX | `ui-ux-designer` | Design, visual components |
| MCP | `mcp-manager` | MCP integrations |

### Delegation Prompt Structure (MANDATORY — ALL 7 sections)

```
1. TASK: Atomic, specific goal (one action per delegation)
2. EXPECTED OUTCOME: Concrete deliverables with success criteria
3. REQUIRED SKILLS: Which skill(s) to activate
4. REQUIRED TOOLS: Explicit tool whitelist (prevents tool sprawl)
5. MUST DO: Exhaustive requirements — leave NOTHING implicit
6. MUST NOT DO: Forbidden actions — anticipate and block rogue behavior
7. CONTEXT: File paths, existing patterns, project constraints
```

After delegation completes, **ALWAYS verify**:
- Does it work as expected?
- Does it follow existing codebase patterns?
- Did the agent follow MUST DO / MUST NOT DO?

### Implementation Chain

```
cook → plan → implement → test → simplify → review → docs → git
```

### Code Changes

- Match existing patterns in `docs/code-standards.md`
- Always use `@riverpod` codegen (never manual providers)
- Always use Freezed for domain entities
- Bugfix Rule: **Fix minimally. NEVER refactor while fixing.**
- Never commit unless explicitly requested

---

## Phase 3 — Verification

### Dart MCP is Default

Use Dart MCP tools (`mcp_dart-mcp-server_*`) for analyze, test, fix, format, pub. Shell only when you need piping/special flags.

### Evidence Requirements (task NOT complete without these)

| Change Type | Required Evidence |
|-------------|-------------------|
| Any code change | `dart analyze` clean (0 errors) |
| Feature/bugfix | `flutter test` passes |
| UI change | Screenshot or visual confirmation |
| Edge Function | curl/HTTP response verified |
| Database migration | SQL applied + verification query |
| Build | `flutter build` exit code 0 |
| Code generation | `build_runner build` succeeds |

**NO EVIDENCE = NOT COMPLETE.**

---

## Phase 4 — Failure Recovery

1. Fire `fix` skill **ALWAYS** before attempting fixes
2. Fix root causes, not symptoms
3. Re-verify after EVERY fix attempt
4. Never shotgun debug (random changes hoping something works)

### After 5 Consecutive Failures

1. **STOP** all further edits immediately
2. **REVERT** to last known working state
3. **DOCUMENT** what was attempted and what failed
4. Fire `problem-solving` skill for structured analysis
5. If still unresolved → **ASK USER** before proceeding

**Never**: Leave code in broken state, continue hoping it works, delete failing tests to "pass"

---

## Phase 5 — Completion

A task is complete when:
- [ ] All planned items marked done
- [ ] `dart analyze` clean on changed files
- [ ] Tests pass (or pre-existing failures explicitly noted)
- [ ] User's original request fully addressed

### Post-Completion

- `docs-manager` agent → update docs if architecture/patterns changed
- `project-manager` agent → update `docs/development-roadmap.md` + `docs/project-changelog.md`
- `git-manager` agent → commit with conventional format (only when requested)

If verification fails:
1. Fix issues caused by YOUR changes
2. Do NOT fix pre-existing issues unless asked
3. Report: "Done. Note: found N pre-existing issues unrelated to my changes."

---

## Dart-Specific Hard Blocks (NEVER violate)

| Constraint | Never |
|------------|-------|
| `// ignore:` lint suppression | Fix the actual issue |
| `as dynamic` type cast | Use proper typing |
| Empty `catch (e) {}` | Always handle or rethrow |
| Manual providers (`StateNotifierProvider`, etc.) | Use `@riverpod` codegen |
| Domain entities without Freezed | Always use `@freezed` |
| Delete failing tests to "pass" | Fix the actual failure |
| Skip `dart analyze` before completion | Always run analysis |
| Suppress Riverpod/Freezed codegen errors | Run `build_runner build` |
| Commit API keys/secrets | Use env config |
| Speculate about unread code | Read first, then act |
