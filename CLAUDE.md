# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Layout (non-obvious)

This repo has 3 active surfaces:

1. **Main Flutter app** (`/`) – end-user app (`name: artio`)
2. **Admin Flutter app** (`/admin`) – template/admin dashboard (`name: artio_admin`)
3. **Supabase backend** (`/supabase`) – SQL migrations + Edge Function (`generate-image`)

When changing behavior, confirm which surface owns it before editing.

## Common Commands

### Main app (`/`)

```bash
# Install deps
flutter pub get

# Codegen (Riverpod/Freezed/go_router)
dart run build_runner build --delete-conflicting-outputs

# Codegen watch mode
dart run build_runner watch

# Run app
flutter run
flutter run -d chrome
flutter run -d windows

# Static analysis + format
flutter analyze
dart format .

# Tests
flutter test
flutter test --coverage
flutter test test/features/auth/data/repositories/auth_repository_test.dart
flutter test test/integration/template_seed_test.dart
flutter test integration_test/template_e2e_test.dart
```

### Admin app (`/admin`)

```bash
# Run inside repo root
cd admin && flutter pub get
cd admin && dart run build_runner build --delete-conflicting-outputs
cd admin && flutter run -d chrome
cd admin && flutter analyze
cd admin && flutter test
```

## Runtime / Environment

- Main app bootstraps env via `String.fromEnvironment('ENV', defaultValue: 'development')` in `lib/main.dart`.
- Supabase config is loaded through `EnvConfig` (`lib/core/config/env_config.dart`).
- Required runtime keys are in `.env` (see `README.md` + `pubspec.yaml` assets section).
- Sentry is initialized during app startup (`lib/main.dart`, `lib/core/config/sentry_config.dart`).

## Architecture (big picture)

## 1) Frontend architecture (main app)

- Feature-first clean architecture under `lib/features/*`.
- Each feature uses: `domain` (interfaces/entities), `data` (repo impl), `presentation` (UI + Riverpod view models/providers).
- Dependency direction is enforced: **Presentation -> Domain <- Data**.

Cross-cutting modules:
- `lib/core/` for config, providers, constants, design system, exceptions, utilities
- `lib/routing/` for GoRouter + typed route definitions
- `lib/shared/` for shared widgets/shell/error UI

## 2) Navigation/auth orchestration

- Router provider: `lib/routing/app_router.dart`
- Typed routes: `lib/routing/routes/app_routes.dart`
- Auth state + redirect logic: `lib/features/auth/presentation/view_models/auth_view_model.dart`

AuthViewModel implements `Listenable` and drives router refresh/redirect behavior.

## 3) Image generation pipeline (core product flow)

Primary flow spans Flutter + Supabase Edge Function:

1. UI/ViewModel starts generation (`create` or `template_engine` view model)
2. Repository calls Supabase function `generate-image`
3. Edge function selects provider (Kie or Gemini), performs generation, mirrors files to Supabase Storage
4. Job rows are updated in `generation_jobs`
5. Flutter listens via realtime stream (`watchJob`) and updates UI

Key files:
- Client repo: `lib/features/template_engine/data/repositories/generation_repository.dart`
- Create flow VM: `lib/features/create/presentation/view_models/create_view_model.dart`
- Template flow VM: `lib/features/template_engine/presentation/view_models/generation_view_model.dart`
- Shared job orchestration: `lib/features/template_engine/presentation/helpers/generation_job_manager.dart`
- Edge function: `supabase/functions/generate-image/index.ts`

## 4) Credits + payment guardrails

Credits are enforced in 2 layers:

- **Client pre-check** in create flow (balance stream via credits provider)
- **Server-authoritative deduction/refund** in edge function (`deduct_credits` / `refund_credits` RPC path)

Key files:
- `lib/features/credits/presentation/providers/credit_balance_provider.dart`
- `supabase/functions/generate-image/index.ts`
- migrations under `supabase/migrations/*create_credit_system.sql`

## Codegen Rules (important)

Generated artifacts are committed and expected (`*.g.dart`, `*.freezed.dart`, router generated files).

After changing any:
- `@riverpod` provider/viewmodel
- Freezed/json entity
- typed route annotation

run:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Do not hand-edit generated files.

## Backend/AI references

- AI model reference source of truth: `docs/kie-api/`
- Supabase edge runtime config: `supabase/config.toml`
- Active function entrypoint: `supabase/functions/generate-image/index.ts`

## Test Layout

Main app tests are split by intent:

- `test/features/` feature unit/widget tests
- `test/core/`, `test/shared/`, `test/routing/` infra/shared tests
- `test/integration/` integration checks
- `integration_test/` end-to-end style flows

When fixing behavior, prefer running the narrowest relevant test file first, then full suite.

## Existing docs to keep aligned

- `README.md`
- `docs/system-architecture.md`
- `docs/code-standards.md`
- `docs/project-overview-pdr.md`
- `docs/codebase-summary.md`
- `docs/development-roadmap.md`

## Global policy inheritance (must follow)

- If privacy hook blocks a sensitive file read, ask for explicit approval via `AskUserQuestion` before reading it.
- Follow modularization guidance from global rules: consider splitting large code files (>200 LOC) by responsibility; do not apply this to markdown/plain-text/config/env/bash files.
