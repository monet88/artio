---
phase: 4
plan: 2
wave: 1
---

# Plan 4.2: Server-Side Ad Reward Logic

## Objective
Create server-side logic that securely awards credits after a rewarded ad view: a Supabase RPC function that atomically validates the daily ad limit, increments the ad view count, awards 5 credits, and logs the transaction. Then create a lightweight `reward-ad` Edge Function that authenticates the user and calls this RPC. After this plan, there's a secure endpoint for awarding ad credits.

## Context
- `.gsd/SPEC.md` — 5 credits per ad, max 10 ads/day, max 50 credits/day
- `supabase/migrations/20260218000000_create_credit_system.sql` — `ad_views` table (user_id, view_date, view_count CHECK ≤10), `user_credits`, `credit_transactions`
- `supabase/functions/generate-image/index.ts` — Existing Edge Function pattern (JWT auth, service_role client, CORS)

## Tasks

<task type="auto">
  <name>Create reward_ad_credits SQL function</name>
  <files>
    supabase/migrations/20260218100000_create_reward_ad_function.sql (CREATE)
  </files>
  <action>
    1. Create a new migration file with a `reward_ad_credits` SECURITY DEFINER function:
       ```sql
       CREATE OR REPLACE FUNCTION reward_ad_credits(p_user_id UUID)
       RETURNS JSON AS $$
       DECLARE
         v_today DATE := CURRENT_DATE;
         v_current_count INTEGER;
         v_new_balance INTEGER;
       BEGIN
         -- Upsert ad_views for today, incrementing count
         INSERT INTO ad_views (user_id, view_date, view_count)
         VALUES (p_user_id, v_today, 1)
         ON CONFLICT (user_id, view_date)
         DO UPDATE SET view_count = ad_views.view_count + 1
         WHERE ad_views.view_count < 10
         RETURNING view_count INTO v_current_count;

         -- If no row returned, daily limit reached
         IF v_current_count IS NULL THEN
           RETURN json_build_object(
             'success', false,
             'error', 'daily_limit_reached',
             'message', 'Maximum 10 ads per day'
           );
         END IF;

         -- Award 5 credits
         UPDATE user_credits
         SET balance = balance + 5
         WHERE user_id = p_user_id
         RETURNING balance INTO v_new_balance;

         -- Log transaction
         INSERT INTO credit_transactions (user_id, amount, type, description)
         VALUES (p_user_id, 5, 'ad_reward', 'Rewarded ad credit');

         RETURN json_build_object(
           'success', true,
           'credits_awarded', 5,
           'new_balance', v_new_balance,
           'ads_today', v_current_count,
           'ads_remaining', 10 - v_current_count
         );
       END;
       $$ LANGUAGE plpgsql SECURITY DEFINER;
       ```

    2. REVOKE from authenticated role (same pattern as deduct_credits):
       ```sql
       REVOKE ALL ON FUNCTION reward_ad_credits(UUID) FROM authenticated;
       ```

    AVOID:
    - Do NOT allow clients to call this RPC directly — only service_role (Edge Function)
    - Do NOT change the ad_views CHECK constraint (view_count <= 10) — the function handles it with the WHERE clause
    - Do NOT award more or fewer than 5 credits per ad
  </action>
  <verify>
    test -f supabase/migrations/20260218100000_create_reward_ad_function.sql
    grep -q "reward_ad_credits" supabase/migrations/20260218100000_create_reward_ad_function.sql
    grep -q "SECURITY DEFINER" supabase/migrations/20260218100000_create_reward_ad_function.sql
    grep -q "REVOKE" supabase/migrations/20260218100000_create_reward_ad_function.sql
  </verify>
  <done>
    - `reward_ad_credits` function created with atomic daily limit check + credit award
    - Returns JSON with success/failure, new balance, ads remaining
    - SECURITY DEFINER + REVOKE from authenticated — only callable via service_role
    - Handles edge case: user_credits row missing (no crash, just no UPDATE)
  </done>
</task>

<task type="auto">
  <name>Create reward-ad Edge Function</name>
  <files>
    supabase/functions/reward-ad/index.ts (CREATE)
  </files>
  <action>
    1. Create `supabase/functions/reward-ad/index.ts` following the generate-image pattern:
       - CORS headers (same pattern as generate-image)
       - OPTIONS preflight handler
       - JWT authentication: extract Bearer token, validate with `supabase.auth.getUser(token)`
       - Call `reward_ad_credits` RPC with the authenticated user's ID:
         ```typescript
         const { data, error } = await supabase.rpc('reward_ad_credits', {
           p_user_id: userId
         });
         ```
       - Response mapping:
         - If RPC error → 500
         - If `data.success === false` → 429 (daily limit reached)
         - If `data.success === true` → 200 with credits_awarded, new_balance, ads_remaining
       - Keep it minimal: no request body needed (user ID comes from JWT)

    AVOID:
    - Do NOT accept user_id from request body — extract from JWT only (security)
    - Do NOT implement Server-Side Verification (SSV) yet — that's a future enhancement
    - Do NOT add any ad validation logic — the function trusts the client called it after showing an ad
    - Keep the function under 100 lines
  </action>
  <verify>
    test -f supabase/functions/reward-ad/index.ts
    grep -q "reward_ad_credits" supabase/functions/reward-ad/index.ts
    grep -q "auth.getUser" supabase/functions/reward-ad/index.ts
  </verify>
  <done>
    - `reward-ad` Edge Function authenticates user via JWT
    - Calls `reward_ad_credits` RPC to atomically award credits
    - Returns 200 with new_balance and ads_remaining on success
    - Returns 429 when daily limit (10 ads) reached
    - Returns 401 for invalid/missing auth
    - Follows the same CORS + error handling pattern as generate-image
  </done>
</task>

## Success Criteria
- [ ] `reward_ad_credits` SQL function exists in a migration file
- [ ] Function atomically checks daily limit, awards 5 credits, logs transaction
- [ ] Function is SECURITY DEFINER, REVOKED from authenticated role
- [ ] `reward-ad` Edge Function authenticates via JWT
- [ ] Edge Function returns structured JSON (credits_awarded, new_balance, ads_remaining)
- [ ] 429 response when daily limit reached
- [ ] No client-side RPC access to reward function
