# Architecture

Artio uses a three-surface Flutter + Supabase architecture:

- Main app: Flutter app for customer-facing creation, gallery, credits, and
  subscriptions.
- Admin app: Flutter Web app for template and dashboard operations.
- Backend: Supabase Postgres, storage, RPCs, and Edge Functions.

## Discovery Before Shape

Before changing architecture, identify:

- Product surfaces: main app, admin app, Supabase backend.
- Runtime stack: Flutter, Riverpod, GoRouter, Supabase, Deno TypeScript.
- Core domains: auth, generation, gallery, credits, subscriptions, templates,
  and admin operations.
- Boundary inputs: user input, API requests, webhooks, jobs, files, credentials,
  env config, and signed URLs.
- Validation ladder: the smallest checks that prove the selected stack.

Record durable stack choices in `docs/decisions/` when they meaningfully
constrain future work.

## Default Layering

### Main app layering

```text
presentation
  <- domain
      <- data
          <- external services and storage
```

### Admin app layering

```text
presentation/providers
  <- Supabase direct calls
      <- Postgres, auth, and storage
```

### Backend layering

```text
action handlers
  <- validation and auth
      <- RPCs and shared helpers
          <- Postgres, storage, and provider APIs
```

## Main App Shape

The main app is feature-first under `lib/features/<feature>/`.

Common layers:

- `domain/` — entities, repositories, and pure rules.
- `data/` — repository implementations and external data sources.
- `presentation/` — screens, widgets, providers, and view models.

Cross-cutting code lives in:

- `lib/core/`
- `lib/routing/`
- `lib/shared/`
- `lib/theme/`

## Main App Runtime Flow

```text
UI -> Riverpod provider/view model -> repository -> Supabase or local service
   -> edge function or RPC -> storage / Postgres / provider API -> UI refresh
```

Important contracts:

- `lib/main.dart` loads env config, initializes Supabase, Sentry, AdMob, and
  RevenueCat where applicable.
- `lib/core/config/env_config.dart` loads `.env.<ENV>` and validates required
  variables.
- `lib/core/constants/ai_models.dart` must stay aligned with
  `supabase/functions/_shared/model_config.ts`.
- Credits and subscription state are server-authoritative.

## Admin App Shape

The admin app is a smaller Flutter Web surface.

- `admin/lib/main.dart` loads `.env.example`, then optional local overrides.
- `admin/lib/core/router/` holds routes.
- `admin/lib/core/shell/` renders the sidebar shell.
- `admin/lib/features/auth/` handles login and logout.
- `admin/lib/features/dashboard/` shows operational metrics.
- `admin/lib/features/templates/` handles template CRUD and reorder.

The admin surface uses Riverpod providers directly and talks to Supabase without
an extra data layer.

## Backend Shape

### Edge Functions

- `generate-image` — generation pipeline, provider routing, credit deduction,
  refund handling, and storage mirroring.
- `reward-ad` — ad nonce and claim flow plus Google SSV verification.
- `revenuecat-webhook` — authoritative subscription tier and credit events.
- `sync-subscription` — RevenueCat V2 entitlement sync.
- `verify-google-purchase` — Google Play purchase credit grant.
- `delete-account` — authenticated account deletion and storage cleanup.

### Shared helpers

- `_shared/cors.ts`
- `_shared/credit_logic.ts`
- `_shared/model_config.ts`

### Storage and data

Key runtime records include:

- `profiles`
- `generation_jobs`
- `credits`
- `subscriptions`
- `templates`
- `generated-images` bucket

## Generation Flow

```text
Create/template UI
  -> generation request
  -> rate limit check
  -> job ownership check
  -> premium check when needed
  -> credit deduction
  -> provider selection (KIE / Gemini / Imagen)
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

## Parse-First Boundary Rule

Unknown data must be parsed at boundaries before it enters inner code.

Boundaries include:

- HTTP request bodies, params, and query strings.
- Session payloads and identity claims.
- Environment variables.
- Database rows returned from external clients.
- Platform shell payloads.
- Deep links, tokens, and signed URLs.
- Provider webhooks, events, and async payloads.

Target flow:

```text
unknown input
  -> parser
  -> typed DTO or command
  -> application use case
  -> domain object/value object
```

## Command/Query Boundary

Commands mutate state and own audit side effects. Queries read state and format
for consumers. Shared rules live in domain/application, not controllers.

## Observability Contract

The server should emit one canonical JSON log line per request with:

- timestamp
- level
- request_id
- user_id when known
- action
- duration_ms
- status_code
- message

Audit logs are product records. Application logs are operational records. Do not
use one as a substitute for the other.

## Boundary Rules To Keep Stable

- Client configuration is for initialization and UX, not trust.
- Credits and subscription state are server-owned.
- Model cost sync must be updated in both client and server code.
- Edge Functions should stay small enough to reason about per request path.
- High-risk changes should update decisions and validation expectations together.

## Notes

This document describes the current runtime shape inferred from the live code,
not a future architecture proposal.
