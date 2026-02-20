---
phase: reward-ad-ssv
plan: 1
wave: 1
---

# Plan 1: Database — Nonce Table + RPC Functions

## Objective
Create the `pending_ad_rewards` table and two RPC functions (`request_ad_nonce`, `claim_ad_reward`) that provide the server-side nonce-based reward validation. This is the foundation — all other plans depend on it.

## Context
- .gsd/phases/reward-ad-ssv/RESEARCH.md (Option B architecture)
- supabase/migrations/20260218100000_create_reward_ad_function.sql (existing `reward_ad_credits` RPC)

## Tasks

<task type="auto">
  <name>Create pending_ad_rewards migration</name>
  <files>supabase/migrations/20260220160000_create_pending_ad_rewards.sql</files>
  <action>
    Create a new migration file with:

    1. **Table `pending_ad_rewards`:**
       - `id UUID PRIMARY KEY DEFAULT gen_random_uuid()`
       - `user_id UUID NOT NULL REFERENCES auth.users(id)`
       - `nonce UUID NOT NULL UNIQUE DEFAULT gen_random_uuid()`
       - `created_at TIMESTAMPTZ NOT NULL DEFAULT now()`
       - `claimed_at TIMESTAMPTZ` (null = unclaimed)
       - Index on `nonce` for fast lookup
       - Index on `(created_at) WHERE claimed_at IS NULL` for cleanup
       - RLS: enable but no policies (accessed only via service_role RPCs)

    2. **Function `request_ad_nonce(p_user_id UUID) RETURNS JSON`:**
       - Check daily limit first: query `ad_views` for today, if `view_count >= 10` return error
       - Insert a new row into `pending_ad_rewards`, return `{ success: true, nonce: <uuid> }`
       - SECURITY DEFINER, REVOKE from authenticated

    3. **Function `claim_ad_reward(p_user_id UUID, p_nonce UUID) RETURNS JSON`:**
       - Atomically UPDATE `pending_ad_rewards` SET `claimed_at = now()`
         WHERE `user_id = p_user_id AND nonce = p_nonce AND claimed_at IS NULL AND created_at > now() - INTERVAL '5 minutes'`
       - If no row returned → return `{ success: false, error: 'invalid_or_expired_nonce' }`
       - If success → call existing daily limit check + credit award logic (same as `reward_ad_credits` but after nonce validation)
       - Return same JSON shape as `reward_ad_credits`: `{ success, credits_awarded, new_balance, ads_today, ads_remaining }`
       - SECURITY DEFINER, REVOKE from authenticated

    **DO NOT** modify the existing `reward_ad_credits` function — keep it for backward compatibility / admin use.
  </action>
  <verify>
    Run: `supabase db diff --local` to verify migration syntax is valid.
    Alternatively: review the SQL for correctness manually.
  </verify>
  <done>
    - pending_ad_rewards table created with correct schema
    - request_ad_nonce RPC exists and checks daily limit
    - claim_ad_reward RPC exists with atomic nonce consumption + credit award
    - Both RPCs are SECURITY DEFINER and revoked from authenticated role
  </done>
</task>

## Success Criteria
- [ ] Migration file created and syntactically valid
- [ ] `request_ad_nonce` returns nonce or daily_limit_reached error
- [ ] `claim_ad_reward` atomically consumes nonce and awards credits
- [ ] Existing `reward_ad_credits` function is untouched
