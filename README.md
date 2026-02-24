# Artio

Cross-platform AI image generation SaaS built with Flutter, Supabase, and Edge Functions.

> Last updated: 2026-02-23 (synced to current codebase)

## Repository Surfaces

- Main app: `/` (Flutter app for Android, iOS, Web, Windows)
- Admin app: `/admin` (Flutter Web admin dashboard)
- Backend: `/supabase` (schema, migrations, edge functions)

## Current Product State (from code)

### Main app (`/`)

- Authentication: email/password, Google OAuth, Apple Sign-In, password reset
- Onboarding + guest browsing flow (users can browse before login)
- Template-based generation with dynamic input fields, including image input upload
- Text-to-image Create flow with model selection and generation options
- Credits + premium gating with 402 handling UI
- Credit history screen and transaction rendering
- Rewarded ad flow for credits (`reward-ad` edge function)
- Subscription paywall + RevenueCat purchase/restore wiring
- Gallery with masonry grid, viewer, download/share/delete
- Content moderation pre-check for prompts
- Offline banner + connectivity-aware UX

### Admin app (`/admin`)

- Admin auth gate and protected routes
- Dashboard stats page
- Template list with search/filter
- Template CRUD (create/edit/delete)
- Drag-and-drop reorder with DB persistence

### Backend (`/supabase`)

- Edge functions:
  - `generate-image`: generation pipeline, model routing, credit deduction/refund, premium checks, rate limit
  - `reward-ad`: ad nonce + claim flow
  - `revenuecat-webhook`: subscription status sync + credit grant
- Migrations for templates, profiles, credits, subscriptions, rate limiting, and generation job fields

## Generation Pipeline

Both Template and Create flows use the same backend path:

`UI -> Repository -> supabase/functions/generate-image -> AI provider -> Storage -> generation_jobs -> UI`

Server-side guardrails currently in place:

- Rate limit: 5 requests / 60 seconds per user (`check_rate_limit`)
- Premium-model enforcement before generation
- Server-authoritative credit deduction (`deduct_credits`)
- Insufficient credits response: HTTP 402
- Credit refund on failure (`refund_credits`, with retry)
- Result mirroring into `generated-images` bucket

## AI Model Support

`lib/core/constants/ai_models.dart` currently defines 18 models:

- KIE models (Imagen, Nano Banana, Flux-2, GPT Image, Seedream)
- Gemini native models (`imagen-4.0-*`, `gemini-*`)
- Image-input capable model filtering via `supportsImageInput`

Model cost and premium flags are synchronized with:

- Client: `lib/core/constants/ai_models.dart`
- Server: `supabase/functions/_shared/model_config.ts`

## Architecture Snapshot

```text
lib/
  core/
  features/
    auth/
    create/
    credits/
    gallery/
    settings/
    subscription/
    template_engine/
  routing/
  shared/
  theme/

admin/
  lib/
    core/
    features/
      auth/
      dashboard/
      templates/

supabase/
  functions/
    generate-image/
    reward-ad/
    revenuecat-webhook/
    _shared/
  migrations/
```

## Getting Started (Main App)

### Prerequisites

- Flutter SDK compatible with Dart `^3.10.7`
- Supabase project (or local Supabase via CLI + Docker)

### Install dependencies

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

### Environment setup

Main app loads env by `--dart-define=ENV=<name>` and reads `.env.<name>`.
Default is `development`, so `.env.development` is required.

Minimal required keys:

```env
SUPABASE_URL=...
SUPABASE_ANON_KEY=...
```

Optional keys already wired in code:

```env
SENTRY_DSN=...
REVENUECAT_APPLE_KEY=...
REVENUECAT_GOOGLE_KEY=...
REVENUECAT_WEB_KEY=...
STRIPE_PUBLISHABLE_KEY=...
GEMINI_API_KEY=...
KIE_API_KEY=...
```

### Run

```bash
# Mobile/Desktop
flutter run --dart-define=ENV=development

# Web
flutter run -d chrome --dart-define=ENV=development

# Staging env
flutter run --dart-define=ENV=staging
```

## Getting Started (Admin App)

```bash
cd admin
flutter pub get
```

Create `admin/.env` with:

```env
SUPABASE_URL=...
SUPABASE_ANON_KEY=...
```

Run admin web:

```bash
flutter run -d chrome
```

## Supabase Local Development

Quick commands:

```bash
supabase start
supabase db reset
supabase functions serve generate-image
```

Set required function secrets:

```bash
supabase secrets set SUPABASE_SERVICE_ROLE_KEY=...
supabase secrets set KIE_API_KEY=...
supabase secrets set GEMINI_API_KEY=...
supabase secrets set REVENUECAT_WEBHOOK_SECRET=...
```

Detailed guide: `docs/local-supabase-setup-guide.md`

## Development Commands

```bash
# Codegen
dart run build_runner build --delete-conflicting-outputs
dart run build_runner watch --delete-conflicting-outputs

# Static analysis
flutter analyze

# Unit/widget tests (default)
flutter test

# Integration-tagged tests
flutter test --tags integration
```

## Test Suite Snapshot

Current test file count in this repo:

- Unit/widget test files: 80 (`test/**/*_test.dart`)
- Integration test files: 5 (`integration_test/*_test.dart`)

## Key Documentation

- `docs/system-architecture.md`
- `docs/code-standards.md`
- `docs/project-overview-pdr.md`
- `docs/development-roadmap.md`
- `docs/project-changelog.md`
- `docs/local-supabase-setup-guide.md`

## Notes

- Some legacy docs may still contain outdated planning statuses; this README reflects the current implementation in code.
- Do not hand-edit generated files (`*.g.dart`, `*.freezed.dart`).
