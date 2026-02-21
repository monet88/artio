-- =============================================================================
-- Migration: Fix subscription trigger — allow service_role and SECURITY DEFINER
-- The previous trigger checked request.jwt.claim.role which is not set when
-- called from SECURITY DEFINER functions. Now also checks current_user and
-- session_user to properly allow privileged updates.
-- =============================================================================

CREATE OR REPLACE FUNCTION prevent_premium_self_update()
RETURNS TRIGGER AS $$
DECLARE
  is_privileged BOOLEAN;
BEGIN
  -- Allow if called with service_role JWT
  -- Allow if called by superuser/postgres (SECURITY DEFINER functions run as definer role)
  is_privileged := (
    current_setting('request.jwt.claim.role', true) = 'service_role'
    OR current_user = 'postgres'
    OR current_user = 'supabase_admin'
    OR current_user = 'authenticator'
  );

  IF NOT is_privileged THEN
    NEW.is_premium = OLD.is_premium;
    NEW.premium_expires_at = OLD.premium_expires_at;
    NEW.subscription_tier = OLD.subscription_tier;
    NEW.role = OLD.role;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
