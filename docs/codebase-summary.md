# Codebase Summary

## Repository Shape

| Path | Purpose |
| --- | --- |
| `lib/` | Main Flutter app source |
| `admin/lib/` | Admin Flutter Web app source |
| `supabase/functions/` | Edge Functions and shared helpers |
| `supabase/migrations/` | Database schema and operational migrations |
| `docs/` | Harness docs plus product docs baseline |
| `test/` | Main app unit, widget, and integration tests |
| `admin/test/` | Admin app tests |
| `scripts/bin/` | Rust Harness CLI and operational scripts |

## Main App (`lib/`)

The main app uses feature-first clean architecture with Riverpod and GoRouter.

### Core areas

- `lib/core/`: config, constants, design system, providers, services, state,
  utilities, and shared widgets.
- `lib/features/auth/`: sign-in, sign-up, reset, guest access, and auth state.
- `lib/features/create/`: template and free-form generation flows.
- `lib/features/credits/`: balance, transactions, and credit-related UI.
- `lib/features/gallery/`: gallery, viewer, download/share/delete behavior.
- `lib/features/settings/`: account and preference screens.
- `lib/features/subscription/`: paywall, purchase, restore, and entitlement UI.
- `lib/features/template_engine/`: template data, policies, and generation input
  assembly.
- `lib/routing/`: typed routing and navigation guards.
- `lib/theme/`: app theme and color system.

### Main app entry points

- `lib/main.dart` initializes `EnvConfig`, Supabase, Sentry, AdMob, and
  RevenueCat, then runs the Riverpod app shell.
- `lib/core/config/env_config.dart` loads `.env.<ENV>` and validates required
  environment variables.

## Admin App (`admin/lib/`)

The admin surface is a separate Flutter Web app with a simpler Riverpod setup.

### Core areas

- `admin/lib/main.dart` loads env defaults, initializes Supabase, and starts
  `AdminApp`.
- `admin/lib/core/router/` holds the router and navigation shell.
- `admin/lib/core/shell/` contains the sidebar scaffold and navigation rail.
- `admin/lib/features/auth/` handles admin login and sign-out.
- `admin/lib/features/dashboard/` shows dashboard data.
- `admin/lib/features/templates/` handles template CRUD and ordering.

## Backend (`supabase/`)

### Edge Functions

- `generate-image/`: generation orchestration, provider routing, storage mirroring,
  rate limiting, premium checks, and credit deduction/refund.
- `reward-ad/`: authenticated request-nonce and claim flow plus Google SSV
  callback verification.
- `revenuecat-webhook/`: RevenueCat event processing for subscription tier and
  credit grants.
- `sync-subscription/`: active-entitlement sync from RevenueCat V2 API.
- `verify-google-purchase/`: Google Play purchase credit grant with idempotency
  guards.
- `delete-account/`: authenticated user deletion and storage cleanup.
- `_shared/`: CORS, credit logic, and model configuration shared by functions.

### Migrations and schema

- `supabase/migrations/` contains the current Postgres schema history.
- The schema covers profiles, templates, credits, subscriptions, generation jobs,
  rate limiting, and security hardening.

## Tests

Current test surface, as reflected in the repo README:

- Main app test files: 82
- Integration test files: 5
- Admin test files: 2

Test structure mirrors source structure, with feature-specific coverage under
`test/features/` and `admin/test/`.

## Configuration Snapshot

| File | Purpose |
| --- | --- |
| `pubspec.yaml` | Main app dependencies, assets, and launcher config |
| `admin/pubspec.yaml` | Admin app dependencies |
| `analysis_options.yaml` | Lint baseline |
| `build.yaml` | Freezed union configuration |
| `dart_test.yaml` | Integration-tag exclusion for normal test runs |
| `supabase/config.toml` | Supabase local/project config |

## Notable Runtime Dependencies

- Flutter + Dart 3.10.x
- Riverpod and Riverpod code generation
- Supabase Flutter and Supabase Edge Functions
- GoRouter for navigation
- Freezed for immutable models and unions
- Sentry, AdMob, RevenueCat, and Flutter dotenv

## Notes

- The repo contains a `.harness-backup/` snapshot with historical docs and logs;
  treat it as archive, not active source.
- AI model costs and premium flags must stay synchronized between the client and
  `supabase/functions/_shared/model_config.ts`.
