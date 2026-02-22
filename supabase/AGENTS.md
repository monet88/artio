# Supabase Backend

Deno Edge Functions + PostgreSQL. Server-authoritative layer for AI generation, credits, and webhooks.

## STRUCTURE

```
supabase/
├── functions/
│   ├── _shared/              # Shared utilities across functions
│   ├── generate-image/       # Core: AI image generation (Kie + Gemini)
│   ├── revenuecat-webhook/   # Subscription event handler
│   └── reward-ad/            # Ad reward credit grant
├── migrations/               # 14 sequential SQL migrations
└── config.toml               # Supabase local dev config
```

## WHERE TO LOOK

| Task | Location |
|------|----------|
| AI generation logic | `functions/generate-image/index.ts` |
| Credit deduction/refund | `functions/generate-image/index.ts` (RPC calls) |
| Subscription webhooks | `functions/revenuecat-webhook/` |
| Ad reward grants | `functions/reward-ad/` |
| Shared function utils | `functions/_shared/` |
| DB schema changes | `migrations/` (append-only, timestamped) |
| Credit system schema | `migrations/20260218000000_create_credit_system.sql` |
| Rate limiting schema | `migrations/20260220170000_create_rate_limit.sql` |

## EDGE FUNCTION: generate-image

Primary business logic entry point:

1. Validates user auth + credit balance (`deduct_credits` RPC)
2. Selects AI provider: Kie (primary) or Gemini (fallback)
3. Calls provider API, receives image
4. Mirrors output to `generated-images` Storage bucket
5. Updates `generation_jobs` table row
6. On failure: `refund_credits` RPC

## CONVENTIONS

| Rule | Detail |
|------|--------|
| Runtime | Deno (TypeScript) |
| Migrations | Append-only, timestamped prefix `YYYYMMDDHHMMSS_` |
| RLS | Row-Level Security on all user-facing tables |
| Credits | Server-authoritative -- never trust client balance |

## ANTI-PATTERNS

| Forbidden | Do Instead |
|-----------|------------|
| Edit existing migration files | Create new migration |
| Trust client-sent credit balance | Always verify server-side via RPC |
| Direct table writes from client | Use Edge Functions or RPC |
