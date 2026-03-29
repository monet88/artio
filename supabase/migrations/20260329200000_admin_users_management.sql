-- =====================================================================
-- Admin Users Management
-- Adds: is_banned column, admin RLS policies, admin RPCs
-- =====================================================================

-- 1. Add is_banned column to profiles
ALTER TABLE profiles
  ADD COLUMN IF NOT EXISTS is_banned BOOLEAN NOT NULL DEFAULT FALSE;

-- 2. RLS: Admin can read ALL profiles (existing policy likely: users read own)
-- NOTE: If policy name conflicts, drop first: DROP POLICY IF EXISTS "admin_read_all_profiles" ON profiles;
CREATE POLICY "admin_read_all_profiles" ON profiles
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM profiles p
      WHERE p.id = auth.uid() AND p.role = 'admin'
    )
  );

-- 3. RLS: Admin can read ALL generation_jobs (for user detail page)
CREATE POLICY "admin_read_all_generation_jobs" ON generation_jobs
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM profiles p
      WHERE p.id = auth.uid() AND p.role = 'admin'
    )
  );

-- 4. RPC: admin_set_credits
-- Sets a user's credit_balance to an exact amount (no negative values)
CREATE OR REPLACE FUNCTION admin_set_credits(
  p_user_id UUID,
  p_amount   INT
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  -- Verify caller is admin
  IF NOT EXISTS (
    SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin'
  ) THEN
    RAISE EXCEPTION 'Access denied: admin role required';
  END IF;

  -- Validate amount
  IF p_amount < 0 THEN
    RAISE EXCEPTION 'Credits cannot be negative';
  END IF;

  UPDATE profiles
    SET credit_balance = p_amount,
        updated_at     = NOW()
  WHERE id = p_user_id;
END;
$$;

-- 5. RPC: admin_set_premium
-- Toggles is_premium and syncs subscription_tier to match
CREATE OR REPLACE FUNCTION admin_set_premium(
  p_user_id    UUID,
  p_is_premium BOOLEAN
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin'
  ) THEN
    RAISE EXCEPTION 'Access denied: admin role required';
  END IF;

  UPDATE profiles
    SET is_premium        = p_is_premium,
        -- Sync tier: premium=true → 'pro', false → 'free'
        subscription_tier = CASE WHEN p_is_premium THEN 'pro' ELSE 'free' END,
        updated_at        = NOW()
  WHERE id = p_user_id;
END;
$$;

-- 6. RPC: admin_set_banned
CREATE OR REPLACE FUNCTION admin_set_banned(
  p_user_id  UUID,
  p_is_banned BOOLEAN
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin'
  ) THEN
    RAISE EXCEPTION 'Access denied: admin role required';
  END IF;

  UPDATE profiles
    SET is_banned  = p_is_banned,
        updated_at = NOW()
  WHERE id = p_user_id;
END;
$$;

-- 7. Lock down RPCs: revoke public, grant only to authenticated
REVOKE ALL ON FUNCTION admin_set_credits  FROM PUBLIC;
REVOKE ALL ON FUNCTION admin_set_premium  FROM PUBLIC;
REVOKE ALL ON FUNCTION admin_set_banned   FROM PUBLIC;

GRANT EXECUTE ON FUNCTION admin_set_credits  TO authenticated;
GRANT EXECUTE ON FUNCTION admin_set_premium  TO authenticated;
GRANT EXECUTE ON FUNCTION admin_set_banned   TO authenticated;
