-- =============================================================================
-- Migration: Fix credit idempotency race condition + add RC user lookup index
-- Fixes: Plan Phase 1 Fix 3 (CRITICAL) + Fix 6 (MEDIUM)
-- =============================================================================

-- 1. Remove duplicate reference_ids (keep the oldest row per reference_id)
DELETE FROM credit_transactions
WHERE id IN (
  SELECT id FROM (
    SELECT id,
           ROW_NUMBER() OVER (
             PARTITION BY reference_id
             ORDER BY created_at ASC, id ASC
           ) AS rn
    FROM credit_transactions
    WHERE reference_id IS NOT NULL
  ) dupes
  WHERE dupes.rn > 1
);

-- 2. UNIQUE partial index on reference_id (replaces existing non-unique index)
-- This prevents concurrent webhooks from double-granting credits.
DROP INDEX IF EXISTS idx_credit_transactions_reference_id;
CREATE UNIQUE INDEX idx_credit_transactions_reference_id
  ON credit_transactions(reference_id)
  WHERE reference_id IS NOT NULL;

-- 2. Update grant function for atomic idempotency using ON CONFLICT
CREATE OR REPLACE FUNCTION grant_subscription_credits(
  p_user_id UUID,
  p_amount INTEGER,
  p_description TEXT,
  p_reference_id TEXT
) RETURNS VOID AS $$
BEGIN
  -- Atomic idempotency via UNIQUE constraint + ON CONFLICT
  INSERT INTO credit_transactions (user_id, amount, type, description, reference_id)
  VALUES (p_user_id, p_amount, 'subscription', p_description, p_reference_id)
  ON CONFLICT (reference_id) WHERE reference_id IS NOT NULL DO NOTHING;

  -- Only update balance if row was actually inserted
  IF FOUND THEN
    UPDATE user_credits
    SET balance = balance + p_amount
    WHERE user_id = p_user_id;
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public;

REVOKE ALL ON FUNCTION grant_subscription_credits(UUID, INTEGER, TEXT, TEXT) FROM authenticated;

-- 3. Index for webhook user lookup by revenuecat_app_user_id (Fix 6)
CREATE INDEX IF NOT EXISTS idx_profiles_revenuecat_app_user_id
  ON profiles (revenuecat_app_user_id)
  WHERE revenuecat_app_user_id IS NOT NULL;
