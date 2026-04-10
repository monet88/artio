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

**Double-grant prevention**: `verify-google-purchase` passes `p_check_recent_grant=true` to `grant_subscription_credits`. `revenuecat-webhook` INITIAL_PURCHASE also passes `p_check_recent_grant=true`. The 25-day guard runs INSIDE the RPC under `pg_advisory_xact_lock` — atomic, no TOCTOU race. Whichever fires first wins; the second gets `{ granted: false, reason: "recent_grant_exists" }` and skips. RENEWAL passes `p_check_recent_grant=false` — deduplication is via `reference_id = eventId` (ON CONFLICT). The guard MUST run inside the RPC; never re-add it as an external SELECT check in edge functions.

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
- **RC webhook auth = raw token, NO Bearer prefix**: RC sends the Authorization header value EXACTLY as configured in the dashboard — it does NOT auto-add `Bearer `. `REVENUECAT_WEBHOOK_SECRET` must store only the raw token. The webhook code compares `authHeader` directly against `REVENUECAT_WEBHOOK_SECRET` (no prefix construction). Set the RC dashboard Authorization field to the same raw token. Mismatch → ALL events 401 until secret is corrected (RC retries non-200 responses). To verify: `curl -X POST -H "Authorization: <raw-token>" -H "Content-Type: application/json" -d '{}' <webhook-url>` → 200 `{"ok":true}` = auth OK (empty body soft-ignored); 401 = token mismatch.

### Environment Setup

- **Two .env scopes**: Flutter app reads `.env.{ENV}` via `flutter_dotenv`; Edge Functions need SEPARATE secrets via `supabase secrets set`. Missing either → silent failures.
- **`--dart-define=ENV` required**: Without it, defaults to `development` but `.env.development` must exist. Common error: app runs but keys are empty strings → blank screens, no crash.
- **RevenueCat keys skip web**: `main.dart` guards with `!kIsWeb` — running `flutter run -d chrome` won't init RevenueCat. Subscription features silently fail on web debug.
- **AdMob app IDs in native config**: `ADMOB_*` env vars alone aren't enough — must ALSO set `com.google.android.gms.ads.APPLICATION_ID` in `AndroidManifest.xml` and `GADApplicationIdentifier` in `Info.plist`. Mismatch → crash on app start.
- **Supabase local vs remote**: `supabase start` uses local instance; app `.env` must point to local URL (`http://127.0.0.1:54321`). Mixing local app + remote DB = auth mismatches.

<!-- gitnexus:start -->
# GitNexus — Code Intelligence

This project is indexed by GitNexus as **artio-pr125** (4021 symbols, 7729 relationships, 30 execution flows). Use the GitNexus MCP tools to understand code, assess impact, and navigate safely.

> If any GitNexus tool warns the index is stale, run `npx gitnexus analyze` in terminal first.

## Always Do

- **MUST run impact analysis before editing any symbol.** Before modifying a function, class, or method, run `gitnexus_impact({target: "symbolName", direction: "upstream"})` and report the blast radius (direct callers, affected processes, risk level) to the user.
- **MUST run `gitnexus_detect_changes()` before committing** to verify your changes only affect expected symbols and execution flows.
- **MUST warn the user** if impact analysis returns HIGH or CRITICAL risk before proceeding with edits.
- When exploring unfamiliar code, use `gitnexus_query({query: "concept"})` to find execution flows instead of grepping. It returns process-grouped results ranked by relevance.
- When you need full context on a specific symbol — callers, callees, which execution flows it participates in — use `gitnexus_context({name: "symbolName"})`.

## When Debugging

1. `gitnexus_query({query: "<error or symptom>"})` — find execution flows related to the issue
2. `gitnexus_context({name: "<suspect function>"})` — see all callers, callees, and process participation
3. `READ gitnexus://repo/artio-pr125/process/{processName}` — trace the full execution flow step by step
4. For regressions: `gitnexus_detect_changes({scope: "compare", base_ref: "main"})` — see what your branch changed

## When Refactoring

- **Renaming**: MUST use `gitnexus_rename({symbol_name: "old", new_name: "new", dry_run: true})` first. Review the preview — graph edits are safe, text_search edits need manual review. Then run with `dry_run: false`.
- **Extracting/Splitting**: MUST run `gitnexus_context({name: "target"})` to see all incoming/outgoing refs, then `gitnexus_impact({target: "target", direction: "upstream"})` to find all external callers before moving code.
- After any refactor: run `gitnexus_detect_changes({scope: "all"})` to verify only expected files changed.

## Never Do

- NEVER edit a function, class, or method without first running `gitnexus_impact` on it.
- NEVER ignore HIGH or CRITICAL risk warnings from impact analysis.
- NEVER rename symbols with find-and-replace — use `gitnexus_rename` which understands the call graph.
- NEVER commit changes without running `gitnexus_detect_changes()` to check affected scope.

## Tools Quick Reference

| Tool | When to use | Command |
|------|-------------|---------|
| `query` | Find code by concept | `gitnexus_query({query: "auth validation"})` |
| `context` | 360-degree view of one symbol | `gitnexus_context({name: "validateUser"})` |
| `impact` | Blast radius before editing | `gitnexus_impact({target: "X", direction: "upstream"})` |
| `detect_changes` | Pre-commit scope check | `gitnexus_detect_changes({scope: "staged"})` |
| `rename` | Safe multi-file rename | `gitnexus_rename({symbol_name: "old", new_name: "new", dry_run: true})` |
| `cypher` | Custom graph queries | `gitnexus_cypher({query: "MATCH ..."})` |

## Impact Risk Levels

| Depth | Meaning | Action |
|-------|---------|--------|
| d=1 | WILL BREAK — direct callers/importers | MUST update these |
| d=2 | LIKELY AFFECTED — indirect deps | Should test |
| d=3 | MAY NEED TESTING — transitive | Test if critical path |

## Resources

| Resource | Use for |
|----------|---------|
| `gitnexus://repo/artio-pr125/context` | Codebase overview, check index freshness |
| `gitnexus://repo/artio-pr125/clusters` | All functional areas |
| `gitnexus://repo/artio-pr125/processes` | All execution flows |
| `gitnexus://repo/artio-pr125/process/{name}` | Step-by-step execution trace |

## Self-Check Before Finishing

Before completing any code modification task, verify:
1. `gitnexus_impact` was run for all modified symbols
2. No HIGH/CRITICAL risk warnings were ignored
3. `gitnexus_detect_changes()` confirms changes match expected scope
4. All d=1 (WILL BREAK) dependents were updated

## Keeping the Index Fresh

After committing code changes, the GitNexus index becomes stale. Re-run analyze to update it:

```bash
npx gitnexus analyze
```

If the index previously included embeddings, preserve them by adding `--embeddings`:

```bash
npx gitnexus analyze --embeddings
```

To check whether embeddings exist, inspect `.gitnexus/meta.json` — the `stats.embeddings` field shows the count (0 means no embeddings). **Running analyze without `--embeddings` will delete any previously generated embeddings.**

> Claude Code users: A PostToolUse hook handles this automatically after `git commit` and `git merge`.

## CLI

| Task | Read this skill file |
|------|---------------------|
| Understand architecture / "How does X work?" | `.claude/skills/gitnexus/gitnexus-exploring/SKILL.md` |
| Blast radius / "What breaks if I change X?" | `.claude/skills/gitnexus/gitnexus-impact-analysis/SKILL.md` |
| Trace bugs / "Why is X failing?" | `.claude/skills/gitnexus/gitnexus-debugging/SKILL.md` |
| Rename / extract / split / refactor | `.claude/skills/gitnexus/gitnexus-refactoring/SKILL.md` |
| Tools, resources, schema reference | `.claude/skills/gitnexus/gitnexus-guide/SKILL.md` |
| Index, status, clean, wiki CLI commands | `.claude/skills/gitnexus/gitnexus-cli/SKILL.md` |

<!-- gitnexus:end -->
