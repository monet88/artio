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
