# Artio — Copilot Instructions

AI art generation SaaS. Flutter/Dart monorepo with three surfaces: **main app** (`/`), **admin app** (`/admin`), **backend** (`/supabase`). Confirm which surface you're editing before making changes.

## Architecture

Feature-first clean architecture under `lib/features/{name}/`. Each feature has three layers:
- **domain/** — entities (`@freezed`), repository interfaces (`I{Name}Repository`)
- **data/** — repository implementations, services (cache, API)
- **presentation/** — screens, widgets, ViewModels (`@riverpod` codegen)

Dependency rule: **Presentation → Domain ← Data**. Never import `data/` from `presentation/`.

Cross-cutting code lives in `lib/core/` (config, constants, design system, exceptions, providers, services, state, utils), `lib/routing/`, `lib/shared/`, `lib/theme/`.

### Generation Pipeline (core product flow)
```
UI/ViewModel → Repository → supabase/functions/generate-image → AI provider (KIE/Gemini) → Storage → generation_jobs (realtime) → UI
```
Credits use two-layer enforcement: client pre-check + server-authoritative `deduct_credits`/`refund_credits` RPC. Insufficient credits → HTTP 402. Keep model costs synced between `lib/core/constants/ai_models.dart` and `supabase/functions/_shared/model_config.ts`.

## Code Patterns

- **State management**: Always use `@riverpod` codegen from `riverpod_annotation` — never manual `StateNotifierProvider`. ViewModels extend `_$ClassName`. Async state via `AsyncValue.guard()`.
- **Entities**: Always `@freezed` with Freezed union config: `union_key: "type"`, `union_value_case: pascal` (see `build.yaml`).
- **Errors**: Sealed `AppException` hierarchy (Freezed union) in `lib/core/exceptions/app_exception.dart` with variants: `NetworkException`, `AuthException`, `StorageException`, `PaymentException`, `GenerationException`, `UnknownException`. Map to user strings via `AppExceptionMapper.toUserMessage()`.
- **Routing**: `@TypedGoRoute` codegen in `lib/routing/routes/app_routes.dart`. Navigate with `const HomeRoute().go(context)` or `TemplateDetailRoute(id: id).push(context)`. Auth guard via router redirect driven by `AuthViewModel` implementing `Listenable`.
- **Imports**: Use `package:artio/...` (not relative `../`). Generated files via `part` directives.
- **Design system**: Use tokens from `lib/core/design_system/` (`AppSpacing`, `AppDimensions`, `AppGradients`) and `lib/theme/app_colors.dart` — never hardcode spacing/colors.

## Naming Conventions

| Type | File | Class |
|------|------|-------|
| Screen | `{name}_screen.dart` | `{Name}Screen` |
| Model | `{name}_model.dart` | `{Name}Model` |
| Repo interface | `i_{name}_repository.dart` | `I{Name}Repository` |
| Repo impl | `{name}_repository.dart` | `{Name}Repository` |
| ViewModel | `{name}_view_model.dart` | `{Name}ViewModel` |
| Provider | `{name}_provider.dart` | `{name}Provider` (camelCase) |

Files: snake_case. Classes: PascalCase. Prefer `const` > `final` > `var`.

## Commands

```bash
# Run app (--dart-define=ENV required)
flutter run --dart-define=ENV=development

# Codegen (after changing @riverpod, @freezed, @TypedGoRoute)
dart run build_runner build --delete-conflicting-outputs

# Static analysis (uses very_good_analysis)
flutter analyze

# Tests (integration tests excluded by default)
flutter test
flutter test --tags integration
```

Never hand-edit `*.g.dart` or `*.freezed.dart` files. Generated files are committed.

## Testing

- Mock library: **mocktail** (not mockito). Shared mocks in `test/core/mocks/`.
- Mock at repository interface level (`MockAuthRepository extends Mock implements IAuthRepository`).
- Supabase future-like builders: use `thenAnswer`, not `thenReturn`.
- For loading state tests: use `Completer<T>()` that never completes, not `Future.delayed`. `Future.delayed` is non-deterministic and causes flaky tests — Completer ensures the provider stays in `AsyncLoading` state deterministically.
- Test structure mirrors `lib/` exactly. E2E flows in `integration_test/`.
- Integration tests are tag-gated (`dart_test.yaml`): excluded from default `flutter test`.

## Backend (Edge Functions)

Edge functions in `supabase/functions/` use Deno/TypeScript. Shared utilities in `_shared/` (CORS, credit logic, model config). Key functions:
- `generate-image` — orchestrates AI generation, model routing, credit deduction/refund
- `revenuecat-webhook` — subscription sync + credit grant
- `reward-ad` — ad nonce + claim flow

## Admin App (`/admin`)

Separate Flutter web app (`admin/pubspec.yaml`). Simpler architecture than main app:
- `core/` — constants, router, shell (scaffold layout), theme, utils
- `features/{name}/` — `domain/entities/`, `presentation/pages/`, `providers/`
- No `data/` layer — providers call Supabase directly
- No `@freezed` entities — plain Dart classes
- Shares Supabase project but has its OWN `.env` and `main.dart`

Key difference: Admin uses `providers/` (plain Riverpod) not `presentation/providers/` with ViewModels.

## Supabase Migrations

Migration naming: `YYYYMMDDHHMMSS_descriptive_name.sql` in `supabase/migrations/`. Create via `supabase migration new <name>` (auto-generates timestamp prefix).

Key conventions:
- All new tables MUST have RLS enabled (`ALTER TABLE ... ENABLE ROW LEVEL SECURITY`)
- `SECURITY DEFINER` functions MUST include `SET search_path = public`
- Credit-related functions use `advisory_xact_lock()` for concurrency safety
- Never use triggers with `SECURITY DEFINER` — breaks `auth.uid()` context

```bash
supabase start                    # Start local Supabase (Docker required)
supabase db reset                 # Reset DB + re-run all migrations
supabase migration new <name>     # Create new migration file
supabase functions serve           # Local edge function server
supabase db diff --local          # Generate migration from local schema changes
```

## Gotchas

- `generation_repository.dart` retry wraps only the edge function call (Step 2), not the full operation — avoid duplicate `generation_jobs` row inserts.
- Job ID comes from DB insert, NOT edge function response.
- `SECURITY DEFINER` on Postgres trigger functions breaks `current_user` checks — avoid.
- Linting: `very_good_analysis` with `public_member_api_docs: false` and `lines_longer_than_80_chars: false`.
- **Credit cost sync is CRITICAL**: `lib/core/constants/ai_models.dart` (client) and `supabase/functions/_shared/model_config.ts` (server) MUST have matching costs. Server is authoritative — client costs are for display only.
- `Purchases.getOfferings().current` can be null if RevenueCat dashboard has no "Current" offering marked — always null-check.
- Admin/DB-premium users (`profiles.is_premium = true`) bypass RevenueCat entirely for subscription status — see `subscription_provider.dart:15`. Don't add RevenueCat checks to admin-granted premium logic.

### Environment Setup

- **Two .env scopes**: Flutter app reads `.env.{ENV}` via `flutter_dotenv`; Edge Functions need SEPARATE secrets via `supabase secrets set`. Missing either → silent failures.
- **`--dart-define=ENV` required**: Without it, defaults to `development` but `.env.development` must exist. Common error: app runs but keys are empty strings → blank screens, no crash.
- **RevenueCat keys skip web**: `main.dart` guards with `!kIsWeb` — running `flutter run -d chrome` won't init RevenueCat. Subscription features silently fail on web debug.
- **AdMob app IDs in native config**: `ADMOB_*` env vars alone aren't enough — must ALSO set `com.google.android.gms.ads.APPLICATION_ID` in `AndroidManifest.xml` and `GADApplicationIdentifier` in `Info.plist`. Mismatch → crash on app start.
- **Supabase local vs remote**: `supabase start` uses local instance; app `.env` must point to local URL (`http://127.0.0.1:54321`). Mixing local app + remote DB = auth mismatches.
