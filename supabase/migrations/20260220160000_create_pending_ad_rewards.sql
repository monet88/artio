-- =============================================================================
-- Migration: Create pending_ad_rewards table + nonce-based reward RPCs
-- Adds server-side nonce validation to prevent reward-ad abuse.
-- =============================================================================

-- 1. Table: pending_ad_rewards
CREATE TABLE pending_ad_rewards (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  nonce UUID NOT NULL UNIQUE DEFAULT gen_random_uuid(),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  claimed_at TIMESTAMPTZ
);

-- Fast lookup by nonce (used in claim_ad_reward)
CREATE INDEX idx_pending_ad_rewards_nonce ON pending_ad_rewards(nonce);

-- Cleanup query for unclaimed expired nonces
CREATE INDEX idx_pending_ad_rewards_cleanup
  ON pending_ad_rewards(created_at)
  WHERE claimed_at IS NULL;

-- RLS enabled but no policies — accessed only via SECURITY DEFINER RPCs
ALTER TABLE pending_ad_rewards ENABLE ROW LEVEL SECURITY;

-- =============================================================================
-- 2. Function: request_ad_nonce
-- Generates a one-time nonce for ad reward claim. Checks daily limit first.
-- =============================================================================

CREATE OR REPLACE FUNCTION request_ad_nonce(p_user_id UUID)
RETURNS JSON AS $$
DECLARE
  v_today DATE := CURRENT_DATE;
  v_current_count INTEGER;
  v_nonce UUID;
BEGIN
  -- Check daily ad limit (same logic as reward_ad_credits)
  SELECT view_count INTO v_current_count
  FROM ad_views
  WHERE user_id = p_user_id AND view_date = v_today;

  IF v_current_count IS NOT NULL AND v_current_count >= 10 THEN
    RETURN json_build_object(
      'success', false,
      'error', 'daily_limit_reached',
      'message', 'Maximum 10 ads per day'
    );
  END IF;

  -- Create a new nonce
  INSERT INTO pending_ad_rewards (user_id)
  VALUES (p_user_id)
  RETURNING nonce INTO v_nonce;

  RETURN json_build_object(
    'success', true,
    'nonce', v_nonce
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Only callable via service_role (Edge Functions)
REVOKE ALL ON FUNCTION request_ad_nonce(UUID) FROM authenticated;

-- =============================================================================
-- 3. Function: claim_ad_reward
-- Atomically consumes a nonce and awards credits. Prevents replay & expiry.
-- =============================================================================

CREATE OR REPLACE FUNCTION claim_ad_reward(p_user_id UUID, p_nonce UUID)
RETURNS JSON AS $$
DECLARE
  v_reward_id UUID;
  v_today DATE := CURRENT_DATE;
  v_current_count INTEGER;
  v_new_balance INTEGER;
BEGIN
  -- Step 1: Atomically claim the nonce (single UPDATE prevents double-spend)
  UPDATE pending_ad_rewards
  SET claimed_at = now()
  WHERE user_id = p_user_id
    AND nonce = p_nonce
    AND claimed_at IS NULL
    AND created_at > now() - INTERVAL '5 minutes'
  RETURNING id INTO v_reward_id;

  IF v_reward_id IS NULL THEN
    RETURN json_build_object(
      'success', false,
      'error', 'invalid_or_expired_nonce',
      'message', 'Nonce is invalid, expired, or already used'
    );
  END IF;

  -- Step 2: Check and increment daily ad count (same as reward_ad_credits)
  INSERT INTO ad_views (user_id, view_date, view_count)
  VALUES (p_user_id, v_today, 1)
  ON CONFLICT (user_id, view_date)
  DO UPDATE SET view_count = ad_views.view_count + 1
    WHERE ad_views.view_count < 10
  RETURNING view_count INTO v_current_count;

  IF v_current_count IS NULL THEN
    RETURN json_build_object(
      'success', false,
      'error', 'daily_limit_reached',
      'message', 'Maximum 10 ads per day'
    );
  END IF;

  -- Step 3: Award 5 credits
  UPDATE user_credits
  SET balance = balance + 5
  WHERE user_id = p_user_id
  RETURNING balance INTO v_new_balance;

  IF v_new_balance IS NULL THEN
    RETURN json_build_object(
      'success', false,
      'error', 'no_credit_record',
      'message', 'User has no credit balance record'
    );
  END IF;

  -- Step 4: Log the transaction
  INSERT INTO credit_transactions (user_id, amount, type, description)
  VALUES (p_user_id, 5, 'ad_reward', 'Rewarded ad credit (nonce-verified)');

  RETURN json_build_object(
    'success', true,
    'credits_awarded', 5,
    'new_balance', v_new_balance,
    'ads_today', v_current_count,
    'ads_remaining', 10 - v_current_count
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Only callable via service_role (Edge Functions)
REVOKE ALL ON FUNCTION claim_ad_reward(UUID, UUID) FROM authenticated;
