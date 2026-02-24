Behavioral guidelines to reduce common LLM coding mistakes. Merge with project-specific instructions as needed.

**Tradeoff:** These guidelines bias toward caution over speed. For trivial tasks, use judgment.

## 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:
- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them - don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

## 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

## 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it - don't delete it.

When your changes create orphans:
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: Every changed line should trace directly to the user's request.

## 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:
- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:
```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.

---

**These guidelines are working if:** fewer unnecessary changes in diffs, fewer rewrites due to overcomplication, and clarifying questions come before implementation rather than after mistakes.

---

## Project Context

Artio is a cross-platform AI image generation SaaS.

- Stack: Flutter 3.10+, Dart 3.10+, Riverpod codegen, GoRouter codegen, Supabase, Freezed
- Surfaces:
  - Main app: `/`
  - Admin app: `/admin`
  - Backend: `/supabase`

Read these docs first before deep code exploration:

- `docs/code-standards.md`
- `docs/system-architecture.md`
- `docs/project-overview-pdr.md`
- `docs/development-roadmap.md`
- `docs/project-changelog.md`

---

## Skill Triggers

Activate matching skills immediately when request fits:

| Trigger | Skill |
|---|---|
| Implement feature / write code | `cook` |
| Fix bug / test failure / runtime error | `fix` |
| Debugging root cause | `debug` |
| Find files / understand codebase areas | `scout` |
| Research best practices / external approach | `research` |
| Planning multi-step implementation | `plan` |
| Architecture trade-off discussion | `brainstorm` |
| Pre-PR or explicit code review request | `code-review` |
| Flutter/mobile implementation patterns | `mobile-development` |
| Supabase/PostgreSQL/schema/RPC work | `databases` |
| Complex multi-step reasoning | `sequential-thinking` |
| Stuck after repeated failures | `problem-solving` |
| Commit/branch/PR workflow | `git` |
| Multi-agent orchestration | `team` |
| External library docs/API lookup | `docs-seeker` |
| MCP capability/tooling questions | `mcp-management` |
| Image/video/document analysis | `ai-multimodal` |

---

## Artio-Specific Implementation Rules

- Confirm owning surface before editing (`/`, `/admin`, `/supabase`)
- Preserve dependency direction: Presentation -> Domain <- Data
- Keep using Riverpod `@riverpod` codegen patterns
- Do not hand-edit generated files (`*.g.dart`, `*.freezed.dart`)
- Use design tokens from `lib/core/design_system/` for UI values

---

## Artio Critical Flow

Generation flow:

`UI/ViewModel -> Repository -> Edge Function -> AI provider -> storage -> generation_jobs realtime -> UI`

Credit enforcement is two-layer and must remain intact:

1. Client pre-check via credits state/stream
2. Server-authoritative deduction via secure RPC (`deduct_credits`)

Insufficient credits must map consistently to the existing 402 handling path.

---

## Quick Map

- Auth: `lib/features/auth/`
- Template engine: `lib/features/template_engine/`
- Create: `lib/features/create/`
- Gallery: `lib/features/gallery/`
- Credits: `lib/features/credits/`
- Subscription: `lib/features/subscription/`
- Settings: `lib/features/settings/`
- Router: `lib/routing/app_router.dart`
- Supabase DI: `lib/core/providers/supabase_provider.dart`
- Edge function: `supabase/functions/generate-image/index.ts`
- Shared edge utils: `supabase/functions/_shared/`

---

## Verification Minimum for This Project

- Dart code change: `dart analyze` clean in changed scope
- Behavior change/bugfix: relevant `flutter test` passes
- Riverpod/Freezed/GoRouter model changes: `build_runner` succeeds
- Edge function changes: function behavior verified
- Migration changes: migration + verification query

If environment blocks execution, report what could not be verified.

---

## Known Gotchas

- Mocktail + Supabase future-like builders: prefer `thenAnswer` over `thenReturn`
- Keep model cost config synchronized between client constants and edge function
- Keep retry scope safe to avoid duplicate generation row inserts

---

## Security Notes

- Never expose secrets/tokens/passwords/JWTs
- Redact sensitive output/logs
- Preserve least-privilege RPC/service-role access patterns
