-- Migration: Fix Function Signatures + Normalize pending_ad_rewards
-- Phase 3: Restore original function return types (JSONB/JSON)
-- Phase 4: Ensure pending_ad_rewards uses original schema (claimed_at)

-- ============================================================
-- Phase 4: Normalize pending_ad_rewards schema
-- Ensure claimed_at column exists, drop sync-schema columns
-- ============================================================

-- Ensure claimed_at column exists (original schema)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'pending_ad_rewards' AND column_name = 'claimed_at'
  ) THEN
    ALTER TABLE pending_ad_rewards ADD COLUMN claimed_at TIMESTAMPTZ;
  END IF;
END $$;

-- Drop sync-schema columns if they exist
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'pending_ad_rewards' AND column_name = 'expires_at'
  ) THEN
    ALTER TABLE pending_ad_rewards DROP COLUMN expires_at;
  END IF;

  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'pending_ad_rewards' AND column_name = 'claimed'
  ) THEN
    ALTER TABLE pending_ad_rewards DROP COLUMN claimed;
  END IF;
END $$;

-- Recreate cleanup index with original schema definition
DROP INDEX IF EXISTS idx_pending_ad_rewards_cleanup;
CREATE INDEX idx_pending_ad_rewards_cleanup
  ON pending_ad_rewards(created_at)
  WHERE claimed_at IS NULL;

-- ============================================================
-- Phase 3: Fix function signatures
-- Must DROP first (can't change return type with CREATE OR REPLACE)
-- ============================================================

-- 1. check_rate_limit — RETURNS JSONB
DROP FUNCTION IF EXISTS check_rate_limit(UUID, INTEGER, INTEGER);

CREATE OR REPLACE FUNCTION check_rate_limit(
    p_user_id UUID,
    p_max_requests INT DEFAULT 5,
    p_window_seconds INT DEFAULT 60
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_row generation_rate_limits%ROWTYPE;
    v_now TIMESTAMPTZ := now();
    v_window_age FLOAT;
    v_remaining INT;
BEGIN
    SELECT * INTO v_row
    FROM generation_rate_limits
    WHERE user_id = p_user_id
    FOR UPDATE;

    IF NOT FOUND THEN
        INSERT INTO generation_rate_limits (user_id, window_start, request_count)
        VALUES (p_user_id, v_now, 1);
        RETURN jsonb_build_object(
            'allowed', true,
            'remaining', p_max_requests - 1
        );
    END IF;

    v_window_age := EXTRACT(EPOCH FROM (v_now - v_row.window_start));

    IF v_window_age >= p_window_seconds THEN
        UPDATE generation_rate_limits
        SET window_start = v_now, request_count = 1
        WHERE user_id = p_user_id;
        RETURN jsonb_build_object(
            'allowed', true,
            'remaining', p_max_requests - 1
        );
    END IF;

    IF v_row.request_count >= p_max_requests THEN
        RETURN jsonb_build_object(
            'allowed', false,
            'remaining', 0,
            'retry_after', CEIL(p_window_seconds - v_window_age)::INT
        );
    END IF;

    UPDATE generation_rate_limits
    SET request_count = request_count + 1
    WHERE user_id = p_user_id;

    v_remaining := p_max_requests - v_row.request_count - 1;
    RETURN jsonb_build_object(
        'allowed', true,
        'remaining', v_remaining
    );
END;
$$;

REVOKE EXECUTE ON FUNCTION check_rate_limit FROM authenticated;
REVOKE EXECUTE ON FUNCTION check_rate_limit FROM anon;

-- 2. request_ad_nonce — RETURNS JSON
DROP FUNCTION IF EXISTS request_ad_nonce(UUID);

CREATE OR REPLACE FUNCTION request_ad_nonce(p_user_id UUID)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_today DATE := CURRENT_DATE;
  v_current_count INTEGER;
  v_nonce UUID;
BEGIN
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

  INSERT INTO pending_ad_rewards (user_id)
  VALUES (p_user_id)
  RETURNING nonce INTO v_nonce;

  RETURN json_build_object('success', true, 'nonce', v_nonce);
END;
$$;

REVOKE ALL ON FUNCTION request_ad_nonce(UUID) FROM authenticated;

-- 3. claim_ad_reward — RETURNS JSON
DROP FUNCTION IF EXISTS claim_ad_reward(UUID, UUID);

CREATE OR REPLACE FUNCTION claim_ad_reward(p_user_id UUID, p_nonce UUID)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_reward_id UUID;
  v_today DATE := CURRENT_DATE;
  v_current_count INTEGER;
  v_new_balance INTEGER;
BEGIN
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

  INSERT INTO ad_views (user_id, view_date, view_count)
  VALUES (p_user_id, v_today, 1)
  ON CONFLICT (user_id, view_date)
  DO UPDATE SET view_count = ad_views.view_count + 1
    WHERE ad_views.view_count < 10
  RETURNING view_count INTO v_current_count;

  IF v_current_count IS NULL THEN
    RETURN json_build_object(
      'success', false, 'error', 'daily_limit_reached',
      'message', 'Maximum 10 ads per day'
    );
  END IF;

  UPDATE user_credits
  SET balance = balance + 5
  WHERE user_id = p_user_id
  RETURNING balance INTO v_new_balance;

  IF v_new_balance IS NULL THEN
    RETURN json_build_object(
      'success', false, 'error', 'no_credit_record',
      'message', 'User has no credit balance record'
    );
  END IF;

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
$$;

REVOKE ALL ON FUNCTION claim_ad_reward(UUID, UUID) FROM authenticated;

-- 4. reward_ad_credits — RETURNS JSON
DROP FUNCTION IF EXISTS reward_ad_credits(UUID);

CREATE OR REPLACE FUNCTION reward_ad_credits(p_user_id UUID)
RETURNS JSON AS $$
DECLARE
  v_today DATE := CURRENT_DATE;
  v_current_count INTEGER;
  v_new_balance INTEGER;
BEGIN
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

REVOKE ALL ON FUNCTION reward_ad_credits(UUID) FROM authenticated;
