# Deployment Guide

## Environments

| Surface | Local | Release |
| --- | --- | --- |
| Main app | Flutter run with `--dart-define=ENV=<name>` | Flutter build targets for mobile, desktop, or web |
| Admin app | `cd admin && flutter run -d chrome` | Admin web build and host deployment |
| Backend | Supabase CLI local stack | Supabase project with secrets set |

## Main App

### Required environment files

- `.env.development`
- `.env.staging`
- `.env.production`

### Required keys

- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`

### Optional keys already used in code

- `SENTRY_DSN`
- `REVENUECAT_APPLE_KEY`
- `REVENUECAT_GOOGLE_KEY`
- `REVENUECAT_WEB_KEY`
- `GEMINI_API_KEY`
- `KIE_API_KEY`

### Common commands

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
flutter run --dart-define=ENV=development
```

## Admin App

### Required environment files

- `admin/.env.example` as fallback defaults
- `admin/.env` as local override

### Required keys

- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`

### Common commands

```bash
cd admin
flutter pub get
flutter run -d chrome
```

## Supabase

### Local development

```bash
supabase start
supabase db reset
supabase functions serve generate-image
```

### Required secrets

- `SUPABASE_SERVICE_ROLE_KEY`
- `KIE_API_KEY`
- `GEMINI_API_KEY`
- `REVENUECAT_WEBHOOK_SECRET`
- `REVENUECAT_SECRET_KEY`
- `REVENUECAT_PROJECT_ID`

### Notes

- Keep function secrets out of Git.
- Confirm the local Supabase CLI can read `supabase/functions/deno.lock`.
- Keep any API key changes mirrored in the docs and in the relevant code paths.
