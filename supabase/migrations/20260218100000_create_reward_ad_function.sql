-- =============================================================================
-- Migration: Create reward_ad_credits function
-- Atomically validates daily ad limit, awards 5 credits, logs transaction
-- =============================================================================

CREATE OR REPLACE FUNCTION reward_ad_credits(p_user_id UUID)
RETURNS JSON AS $$
DECLARE
  v_today DATE := CURRENT_DATE;
  v_current_count INTEGER;
  v_new_balance INTEGER;
BEGIN
  -- Upsert ad_views for today, incrementing count.
  -- The WHERE clause ensures we never exceed 10 (matches CHECK constraint).
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

  -- If user has no credit row, this is an error state
  IF v_new_balance IS NULL THEN
    RETURN json_build_object(
      'success', false,
      'error', 'no_credit_record',
      'message', 'User has no credit balance record'
    );
  END IF;

  -- Log the ad reward transaction
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

-- Only callable via service_role (Edge Functions), not by authenticated clients
REVOKE ALL ON FUNCTION reward_ad_credits(UUID) FROM authenticated;
