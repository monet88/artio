# Flutter Project Instructions & Best Practices

As an AI agent working on this repository, you MUST adhere to the following core principles and coding standards. These are synthesized from the individual skills in the `.claude/skills/` directory.

## Core Tech Stack
- **Language**: Dart 3 (Strong typing, null safety, exhaustive switch expressions)
- **Framework**: Flutter
- **State Management**: Riverpod (`@riverpod` codegen, `riverpod_annotation`)
- **Dependency Injection**: Riverpod providers (no `get_it` / `injectable`)
- **Architecture**: Clean Architecture (Data → Domain → Presentation)

## Coding Standards
- **Naming**: `PascalCase` for classes, `camelCase` for variables/functions, `snake_case` for files.
- **Strong Typing**: NO `dynamic`. Use `Object?` or explicit types.
- **Conciseness**: Keep files < 300 lines. Keep functions short (< 50 lines).
- **Null Safety**: Avoid `!` operator. Prefer pattern matching or early returns.
- **Logging**: Use `Log` class (from `app_logger.dart`). Avoid raw `print()`. `debugPrint` OK for non-critical init failures only.

## Architecture & Data
- **Repository Pattern**: DataSources handle raw IO (Dio, Isar, Firebase). Repositories handle orchestrating and domain mapping.
- **Models**: Use `fromJson`/`toJson` factories. Data models live in `data/`, Domain entities in `domain/`, and UI states in `presentation/`.
- **Forms**: Manage form state in BLoCs. Use pure validator functions in the domain layer.

## UI & UX (Design System)
- **Design Tokens**: ZERO hardcoded colors or spacing. Use `AppColors`, `AppSpacing`, `AppDimensions`, `AppGradients`.
- **Widget Lifecycle**: Declare controllers/nodes as `late final` in `initState()` and dispose in `dispose()`.
- **Performance**: NO heavy work in `build()`. Mandate isolates for JSON parsing > 1MB.
- **Patterns**: NO nested ScrollViews in same direction. NO private `_buildWidget` methods (extract into classes). Use Slivers for complex lists.

## Git Workflow
- **Atomic Commits**: One commit = one logical change. Follow Conventional Commits: `type(scope): description`.
- **Commit Bodies**: Include sub-messages to explain the "why" and "how" of changes.
- **Pull Requests**: Ensure zero analysis warnings and passing tests before PR. Provide descriptive titles and internal/external change summaries.

## Security
- **Sensitive Data**: Use `flutter_secure_storage` for tokens and secrets (when adding token caching). Current non-sensitive prefs use `SharedPreferences`.
- **Traffic**: All API communication MUST use HTTPS.

## Testing Strategy (100% Coverage)
- **Structure**: All test files MUST strictly mirror the `lib/` directory structure.
- **Mocks**: Use `mocktail` for all dependency mocking.
- **Principles**: 100% logic coverage for domain and bloc layers. Each test must be independent.

## Environment & Flavors
- **Configuration**: Use a single `main.dart`. Pass `--dart-define=ENV=development` (or `staging`). Env values loaded via `flutter_dotenv` from `.env.{ENV}` files.
- **Secrets**: NEVER commit production secrets to Git. Use `.env.example` for key documentation.

---
> Refer to specific files inside `.claude/skills/` for detailed rules on Networking, UI/UX, etc.

# Artio

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
- `verify-google-purchase` — fast-path credit grant after purchase (non-blocking, called by Flutter)
- `sync-subscription` — syncs tier/expiry from RevenueCat V2 API (no credit grant)
- `revenuecat-webhook` — authoritative subscription + credit grant (server-to-server, Pub/Sub pipeline)
- `reward-ad` — ad nonce + claim flow

### IAP / RevenueCat Critical Facts

**Edge function responsibilities** (never mix these up):
- `verify-google-purchase`: grants credits ONLY — does NOT update subscription tier (prevents client-side tier escalation via `productId`)
- `sync-subscription`: updates tier/expiry ONLY — does NOT grant credits
- `revenuecat-webhook`: both tier + credits — authoritative source

**`--no-verify-jwt` required** for all Flutter-called functions: Supabase gateway uses HS256 but GoTrue v2 issues ES256 tokens — mismatch → 401 for all requests. Functions validate JWT internally via `auth.getUser()`.

**Double-grant prevention**: Both `verify-google-purchase` and `revenuecat-webhook` INITIAL_PURCHASE check `credit_transactions WHERE type='subscription' AND created_at > 25 days ago`. Whichever fires first wins; the second skips. The rate-limit query MUST use `type='subscription'` — that's what `grant_subscription_credits` RPC inserts. Using `type='subscription_credit'` makes the guard a no-op.

**Downgrade**: Pass `p_tier: 'free'` (NOT `null`) to `update_subscription_status` — `subscription_tier` column default is `'free'`, not null.

**Flutter**: After `Purchases.purchase()`, both `_verifyWithGooglePlay()` and `_syncToSupabase()` are called with `unawaited()` — non-blocking so success UI shows immediately. `StoreTransaction.transactionIdentifier` on Android = orderId (`GPA.xxx`), NOT purchaseToken.

**`.env.production` safety**: `SUPABASE_SERVICE_ROLE_KEY`, `GEMINI_API_KEY`, `KIE_API_KEY` must NEVER be in `.env.production` (bundled in APK). Set via `supabase secrets set KEY=value --project-ref kytbmplsazsiwndppoji`. Safe to bundle: `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `REVENUECAT_*_KEY`, `ADMOB_*`.

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