# System Architecture

## High-Level Shape

```text
Main Flutter app        Admin Flutter Web app
        |                         |
        v                         v
   Riverpod / GoRouter       Riverpod providers / router
        |                         |
        +----------- Supabase -----+
                    |   |   |
                    |   |   +--> Storage buckets
                    |   +-------> Postgres + RPCs
                    +-----------> Edge Functions
                                   |
                                   +--> AI providers
                                   +--> RevenueCat
                                   +--> Google AdMob / Google Play
```

## Main App Flow

### App bootstrap

1. `lib/main.dart` loads `EnvConfig` from `--dart-define=ENV=<name>`.
2. Supabase is initialized with the configured URL and anon key.
3. Sentry initializes non-blockingly.
4. AdMob initializes after the iOS ATT prompt when applicable.
5. RevenueCat initializes on native platforms when keys are present.
6. The Riverpod app shell starts with typed routing and theming.

### Generation flow

```text
UI -> ViewModel/Provider -> Repository -> generate-image function
   -> provider selection (KIE / Gemini / Imagen)
   -> credit check + deduct
   -> provider call
   -> storage upload or mirror
   -> generation_jobs update
   -> UI refresh
```

Current guardrails:

- Rate limiting happens before generation work starts.
- Premium models are blocked unless the user is premium.
- Credits are deducted server-side.
- Failed post-deduction work triggers a refund attempt.
- Results are mirrored into `generated-images`.

### Authentication and config

- Env loading uses `.env.<ENV>` files.
- Auth flows support email/password, Google OAuth, Apple Sign-In, and reset.
- Guest browsing is allowed before login.
- Sensitive secrets stay outside the repo.

## Admin App Flow

- `admin/lib/main.dart` loads `.env.example` first, then optional local overrides.
- Supabase is initialized with the admin anon key.
- `AdminShell` renders a sidebar-based navigation rail.
- Admin auth gates the dashboard and template management pages.
- Template changes persist through Supabase-backed providers.

## Backend Flow

### `generate-image`

- Validates JWT and request shape.
- Checks rate limits and job ownership.
- Enforces premium access before charging credits.
- Deducts credits using server-side RPCs.
- Calls KIE, Gemini, or Imagen based on model routing.
- Uploads or mirrors outputs into storage.
- Updates `generation_jobs` with status and result URLs.
- Refunds credits if post-deduction work fails.

### Subscription and credit flows

| Function | Responsibility | Ownership rule |
| --- | --- | --- |
| `verify-google-purchase` | Grant subscription credits for Google Play purchase | Credits only; does not set tier |
| `sync-subscription` | Reconcile tier and expiry from RevenueCat entitlements | Tier only; does not grant credits |
| `revenuecat-webhook` | Process authoritative RevenueCat events | Tier plus credits for supported events |

Important constraints:

- `update_subscription_status` is the source of subscription tier truth.
- `grant_subscription_credits` handles idempotent credit grants.
- Downgrades write `free`, not `null`.
- `revenuecat-webhook` validates the raw Authorization header token.
- `verify-google-purchase` uses the Google Play order ID format as its
  idempotency key.

### Account deletion

- `delete-account` authenticates the user with Supabase JWT.
- It removes generated images and uploaded inputs from storage.
- It then deletes the auth user, which cascades related database records.

## Data Layer

Key operational tables and storage areas include:

- `profiles`
- `generation_jobs`
- `credits`
- `subscriptions`
- `templates`
- `generated-images` storage bucket

## Shared Backend Helpers

- `_shared/cors.ts`
- `_shared/credit_logic.ts`
- `_shared/model_config.ts`

The shared model config is a critical contract: the client model list and server
model cost/premium flags must stay aligned.

## Boundaries to Keep Stable

- Client configuration is for initialization and UX, not trust.
- Credits and subscription state are server-owned.
- Model cost sync must be updated in both client and server code.
- Edge Functions should remain small enough to reason about per request path.

## Notes

This document describes the current runtime shape inferred from the live code,
not a future architecture proposal.
