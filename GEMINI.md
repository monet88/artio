## Project Context

**Artio** — AI art generation app (Flutter/Dart). Monorepo: mobile app (`lib/`) + admin dashboard (`admin/`).

- **Stack:** Flutter 3 · Riverpod (codegen) · GoRouter · Supabase (Auth/DB/Storage/Edge Functions) · Freezed · Sentry
- **Architecture:** Clean Architecture per feature (`data/domain/presentation`), 5 features: auth, template_engine, create, gallery, settings
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

## GitHub

Always use **GitHub MCP tools** (`github-mcp-server`) for GitHub operations (PRs, branches, commits, issues, code search). Faster and more reliable than shell `git`/`gh` commands.

---

## Development Rules

**Principles:** YAGNI · KISS · DRY — always.

Detailed rules in `.agent/rules/`:
- **`coding-style.md`** — Immutability, file org (≤250 lines), error handling, quality checklist
- **`security.md`** — Pre-commit security checks, secret management
- **`git-workflow.md`** — Conventional commits, PR workflow, pre-push requirements
- **`testing.md`** — TDD (red/green/refactor), 80%+ coverage, mocktail
- **`patterns.md`** — Repository pattern, Freezed entities, Riverpod state, error handling flow

---