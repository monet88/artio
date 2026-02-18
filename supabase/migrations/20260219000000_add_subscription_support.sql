-- =============================================================================
-- Migration: Add Subscription Support
-- Depends on: 20260218000000_create_credit_system.sql (credit_transactions table
-- and its reference_id column).
-- Adds subscription columns to profiles, plus helper functions for
-- granting subscription credits and updating subscription status.
-- =============================================================================

-- =============================================================================
-- 1. Add subscription columns to profiles
-- =============================================================================

ALTER TABLE profiles ADD COLUMN IF NOT EXISTS is_premium BOOLEAN DEFAULT FALSE;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS premium_expires_at TIMESTAMPTZ;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS subscription_tier TEXT;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS revenuecat_app_user_id TEXT;

-- =============================================================================
-- 2. grant_subscription_credits — idempotent credit granting
-- =============================================================================

CREATE OR REPLACE FUNCTION grant_subscription_credits(
  p_user_id UUID,
  p_amount INTEGER,
  p_description TEXT,
  p_reference_id TEXT
) RETURNS VOID AS $$
BEGIN
  -- Idempotency: skip if this reference_id was already processed
  IF EXISTS (
    SELECT 1 FROM credit_transactions WHERE reference_id = p_reference_id
  ) THEN
    RAISE NOTICE 'grant_subscription_credits: reference_id % already exists, skipping', p_reference_id;
    RETURN;
  END IF;

  UPDATE user_credits
  SET balance = balance + p_amount
  WHERE user_id = p_user_id;

  INSERT INTO credit_transactions (user_id, amount, type, description, reference_id)
  VALUES (p_user_id, p_amount, 'subscription', p_description, p_reference_id);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Only service_role should call this function
REVOKE ALL ON FUNCTION grant_subscription_credits(UUID, INTEGER, TEXT, TEXT) FROM authenticated;

-- =============================================================================
-- 3. update_subscription_status — updates profiles subscription fields
-- =============================================================================

CREATE OR REPLACE FUNCTION update_subscription_status(
  p_user_id UUID,
  p_is_premium BOOLEAN,
  p_tier TEXT,
  p_expires_at TIMESTAMPTZ
) RETURNS VOID AS $$
BEGIN
  UPDATE profiles
  SET
    is_premium = p_is_premium,
    subscription_tier = p_tier,
    premium_expires_at = p_expires_at
  WHERE id = p_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Only service_role should call this function
REVOKE ALL ON FUNCTION update_subscription_status(UUID, BOOLEAN, TEXT, TIMESTAMPTZ) FROM authenticated;
