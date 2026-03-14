-- =============================================================================
-- Migration: Fix TOCTOU double-grant race condition in grant_subscription_credits
--
-- Problem: Two callers (verify-google-purchase + revenuecat-webhook INITIAL_PURCHASE)
-- use different reference_id formats (gp-GPA.xxx vs RC event UUID), so ON CONFLICT
-- dedup does not fire between them. The external 25-day guard (SELECT then RPC) was
-- a TOCTOU race — both callers could pass the guard concurrently and both grant.
--
-- Fix:
--   1. Move the advisory lock INTO the function so the guard + insert are atomic.
--   2. Add optional p_check_recent_grant param that performs the 25-day guard
--      inside the same transaction, under the lock.
--   3. Return JSONB so callers can distinguish: granted=true, duplicate_reference_id,
--      or recent_grant_exists (instead of opaque VOID).
-- =============================================================================

-- Must DROP the old VOID-returning function before replacing with JSONB return type.
-- CREATE OR REPLACE cannot change the return type.
DROP FUNCTION IF EXISTS grant_subscription_credits(UUID, INTEGER, TEXT, TEXT);

CREATE FUNCTION grant_subscription_credits(
  p_user_id        UUID,
  p_amount         INTEGER,
  p_description    TEXT,
  p_reference_id   TEXT,
  p_check_recent_grant BOOLEAN DEFAULT FALSE
) RETURNS JSONB AS $$
DECLARE
  v_lock_key BIGINT;
BEGIN
  -- Advisory lock scoped to this user to serialize concurrent grant attempts.
  -- hashtext produces a stable INT4; casting to BIGINT satisfies pg_advisory_xact_lock.
  v_lock_key := hashtext(p_user_id::TEXT)::BIGINT;
  PERFORM pg_advisory_xact_lock(v_lock_key);

  -- Optional 25-day recent-grant guard (for INITIAL_PURCHASE paths where two callers
  -- with different reference_ids may race — ON CONFLICT alone won't deduplicate them).
  IF p_check_recent_grant THEN
    IF EXISTS (
      SELECT 1
      FROM credit_transactions
      WHERE user_id   = p_user_id
        AND type      = 'subscription'
        AND created_at > now() - INTERVAL '25 days'
    ) THEN
      RETURN jsonb_build_object('granted', false, 'reason', 'recent_grant_exists');
    END IF;
  END IF;

  -- Atomic idempotency via UNIQUE constraint + ON CONFLICT
  INSERT INTO credit_transactions (user_id, amount, type, description, reference_id)
  VALUES (p_user_id, p_amount, 'subscription', p_description, p_reference_id)
  ON CONFLICT (reference_id) WHERE reference_id IS NOT NULL DO NOTHING;

  -- Only update balance if the row was actually inserted
  IF FOUND THEN
    UPDATE user_credits
    SET balance = balance + p_amount
    WHERE user_id = p_user_id;

    RETURN jsonb_build_object('granted', true);
  END IF;

  -- Row already existed (same reference_id) — idempotent no-op
  RETURN jsonb_build_object('granted', false, 'reason', 'duplicate_reference_id');
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public;

REVOKE ALL ON FUNCTION grant_subscription_credits(UUID, INTEGER, TEXT, TEXT, BOOLEAN) FROM authenticated;
