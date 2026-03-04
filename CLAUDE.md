# Artio Project Guidelines

AI art generation SaaS. Flutter/Dart monorepo with 3 active surfaces:

1. **Main app** (`/`) — end-user mobile app (`name: artio`)
2. **Admin app** (`/admin`) — template/admin dashboard (`name: artio_admin`)
3. **Backend** (`/supabase`) — SQL migrations + Edge Functions

**Stack:** Flutter 3.10+ / Dart 3.10+ / Riverpod codegen / GoRouter codegen / Supabase (Auth/DB/Storage/Edge Functions) / Freezed / Sentry

> **Always read existing context first** — `docs/code-standards.md`, `docs/system-architecture.md`, `docs/project-overview-pdr.md`, `docs/development-roadmap.md`, `docs/project-changelog.md`, project memories — before analyzing source code.

---

## Architecture

Feature-first clean architecture under `lib/features/*`.
Each feature: `domain/` (interfaces/entities) · `data/` (repo impl) · `presentation/` (UI + Riverpod VMs).
Dependency direction: **Presentation -> Domain <- Data**.

Cross-cutting: `lib/core/` (config, providers, design system, exceptions, utilities) · `lib/routing/` (GoRouter + typed routes) · `lib/shared/` (shared widgets/shell/error UI)

### Navigation & Auth

- Router: `lib/routing/app_router.dart` · Routes: `lib/routing/routes/app_routes.dart`
- AuthViewModel implements `Listenable`, drives router refresh/redirect

### Image Generation Pipeline (core product flow)

```
UI/ViewModel -> Repository -> Edge Function -> AI provider (Kie/Gemini) -> Storage -> generation_jobs realtime -> UI
```

Key files:
- Client repo: `lib/features/template_engine/data/repositories/generation_repository.dart`
- Create VM: `lib/features/create/presentation/view_models/create_view_model.dart`
- Template VM: `lib/features/template_engine/presentation/view_models/generation_view_model.dart`
- Job orchestration: `lib/features/template_engine/presentation/helpers/generation_job_manager.dart`
- Edge function: `supabase/functions/generate-image/index.ts`

### Credits (two-layer enforcement)

1. **Client pre-check** — balance stream via credits provider
2. **Server-authoritative** — `deduct_credits` / `refund_credits` RPC in edge function

Insufficient credits must map to existing 402 handling path.

---

## Quick Map

| Domain | Path |
|--------|------|
| Auth | `lib/features/auth/` |
| Template Engine | `lib/features/template_engine/` |
| Create | `lib/features/create/` |
| Gallery | `lib/features/gallery/` |
| Credits | `lib/features/credits/` |
| Subscription | `lib/features/subscription/` |
| Settings | `lib/features/settings/` |
| Router | `lib/routing/app_router.dart` |
| Design System | `lib/core/design_system/` |
| Supabase DI | `lib/core/providers/supabase_provider.dart` |
| Edge Functions | `supabase/functions/generate-image/index.ts` |
| Shared Edge Utils | `supabase/functions/_shared/` |
| AI Model Docs | `docs/kie-api/` |

---

## Codegen

Generated files committed (`*.g.dart`, `*.freezed.dart`, router files). After changing `@riverpod` / Freezed / typed route annotations, run `build_runner build`. Do not hand-edit generated files.

---

## Project-Specific Rules

- Confirm owning surface before editing (`/`, `/admin`, `/supabase`)
- Always use `@riverpod` codegen (never manual `StateNotifierProvider` etc.)
- Always use `@freezed` for domain entities
- Use design tokens from `lib/core/design_system/` for UI values
- Env config via `EnvConfig` (`lib/core/config/env_config.dart`)
- Sentry: `lib/main.dart` + `lib/core/config/sentry_config.dart`
- Prefer Dart MCP tools over shell commands (see section below)

---

## Dart MCP Tools

Use `mcp__dart__*` tools for language-aware operations. Shell only when piping/special flags needed.

| Tool | Use When |
|------|----------|
| `hover` | Type info, docs, inferred types for a symbol |
| `resolve_workspace_symbol` | Find symbol declarations by name across workspace |
| `signature_help` | Function/method parameter info at call site |
| `analyze_files` | Static analysis — errors/warnings/lints |
| `dart_fix` | Auto-fix lint issues |
| `dart_format` | Format Dart files |
| `run_tests` | Run Dart/Flutter tests |
| `pub` | pub get, upgrade, etc. |
| `pub_dev_search` | Search pub.dev for packages |

---

## Known Gotchas

- Mocktail + Supabase future-like builders: use `thenAnswer` over `thenReturn`
- Keep model cost config synced between client constants and edge function
- Keep retry scope safe — avoid duplicate `generation_jobs` row inserts
- `generation_repository.dart` retry wraps only Step 2 (edge function call), not full operation
- Job ID comes from DB insert, NOT Edge Function response
- `SECURITY DEFINER` on trigger functions breaks `current_user` checks — avoid
- Preserve least-privilege RPC/service-role access patterns

---

## Test Layout

- `test/features/` — feature unit/widget tests
- `test/core/`, `test/shared/`, `test/routing/` — infra/shared
- `test/integration/` — integration checks
- `integration_test/` — end-to-end flows

---