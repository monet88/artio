---
phase: 5
plan: 1
wave: 1
---

# Plan 5.1: Database + Webhook Edge Function

## Objective
Add subscription-related database columns, credit-granting SQL function, and the RevenueCat webhook Edge Function that processes subscription lifecycle events (purchase, renewal, cancellation, expiration).

This is the backend foundation — no client-side changes yet.

## Context
- `.gsd/SPEC.md` — Subscription tiers, credit amounts
- `.gsd/phases/5/RESEARCH.md` — Webhook design, SQL function design
- `supabase/migrations/20260218000000_create_credit_system.sql` — Existing credit system
- `supabase/functions/reward-ad/index.ts` — Existing Edge Function pattern

## Tasks

<task type="auto">
  <name>Add subscription columns and grant function</name>
  <files>supabase/migrations/20260219000000_add_subscription_support.sql</files>
  <action>
    Create a new SQL migration that:
    1. Adds columns to `profiles` table:
       - `is_premium BOOLEAN DEFAULT FALSE`
       - `premium_expires_at TIMESTAMPTZ`
       - `subscription_tier TEXT` (nullable — 'pro' or 'ultra')
       - `revenuecat_app_user_id TEXT` (nullable — for linking)
    2. Creates `grant_subscription_credits(p_user_id UUID, p_amount INT, p_description TEXT, p_reference_id TEXT)` 
       — SECURITY DEFINER function that adds credits to `user_credits` and inserts a `credit_transactions` row with type='subscription'
       — Must be idempotent: check `reference_id` doesn't already exist in `credit_transactions` before granting
       — REVOKE from `authenticated` role (service_role only)
    3. Creates `update_subscription_status(p_user_id UUID, p_is_premium BOOLEAN, p_tier TEXT, p_expires_at TIMESTAMPTZ)`
       — SECURITY DEFINER function that updates `profiles` subscription fields
       — REVOKE from `authenticated` role
    
    Important:
    - Use `ALTER TABLE profiles ADD COLUMN IF NOT EXISTS` for safety
    - The `reference_id` uniqueness check in `grant_subscription_credits` prevents double-crediting from duplicate webhooks
  </action>
  <verify>
    Review migration SQL for correctness:
    - All columns use IF NOT EXISTS
    - Functions are SECURITY DEFINER
    - REVOKE statements present
    - Idempotency check on reference_id
  </verify>
  <done>Migration file exists with correct DDL, functions, and security constraints</done>
</task>

<task type="auto">
  <name>Create RevenueCat webhook Edge Function</name>
  <files>supabase/functions/revenuecat-webhook/index.ts</files>
  <action>
    Create a new Supabase Edge Function that:
    1. Accepts POST requests from RevenueCat webhooks
    2. Verifies the `Authorization` header matches the `REVENUECAT_WEBHOOK_SECRET` env var
    3. Parses the webhook body (RevenueCat V2 webhook format):
       - Extract `event.type`, `event.id`, `event.app_user_id`, `event.product_id`
    4. Handles these event types:
       - `INITIAL_PURCHASE`: Call `update_subscription_status(true, tier, expiry)` + `grant_subscription_credits(amount, event_id)`
       - `RENEWAL`: Call `grant_subscription_credits(amount, event_id)` 
       - `CANCELLATION`: Log only (user keeps access until expiry)
       - `EXPIRATION`: Call `update_subscription_status(false, null, null)`
       - `PRODUCT_CHANGE`: Update tier, optionally grant prorated credits
       - `BILLING_ISSUES_DETECTED`: Log warning
    5. Determines tier and credit amount from product_id:
       - `artio_pro_*` → tier='pro', credits=200
       - `artio_ultra_*` → tier='ultra', credits=500
    6. Returns 200 for all events (even unhandled ones) to prevent retries
    7. Uses `createClient` with service_role key for DB operations
    
    Important:
    - Do NOT use JWT verification (verify_jwt=false) — webhooks come from RevenueCat, not authenticated users
    - Use the same Supabase client pattern as `reward-ad/index.ts`
    - Map `event.app_user_id` to Supabase user ID (they should be the same — we set it during RC initialization)
  </action>
  <verify>
    Review the Edge Function for:
    - Auth header verification present
    - All 6 event types handled
    - Idempotent credit granting (via reference_id = event.id)
    - Returns 200 for all events
    - Uses service_role key
    - No hardcoded secrets
  </verify>
  <done>Edge Function handles all subscription lifecycle events with idempotent credit granting</done>
</task>

## Success Criteria
- [ ] Migration adds `is_premium`, `premium_expires_at`, `subscription_tier`, `revenuecat_app_user_id` to profiles
- [ ] `grant_subscription_credits` is idempotent (duplicate event_id = no-op)
- [ ] `update_subscription_status` updates profiles correctly
- [ ] Webhook Edge Function handles INITIAL_PURCHASE, RENEWAL, CANCELLATION, EXPIRATION, PRODUCT_CHANGE
- [ ] Webhook auth header is verified
- [ ] All SQL functions are SECURITY DEFINER with REVOKE from authenticated
