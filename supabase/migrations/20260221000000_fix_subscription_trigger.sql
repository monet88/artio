-- =============================================================================
-- Migration: Fix subscription trigger — protect premium fields from self-update
-- Uses request.jwt.claim.role + current_user to allow only service_role JWT,
-- postgres, and supabase_admin to modify subscription columns.
-- Runs as INVOKER (not SECURITY DEFINER) so current_user reflects the caller.
-- =============================================================================

CREATE OR REPLACE FUNCTION prevent_premium_self_update()
RETURNS TRIGGER AS $$
DECLARE
  is_privileged BOOLEAN;
BEGIN
  -- Allow if called with service_role JWT or by superuser/postgres
  is_privileged := (
    current_setting('request.jwt.claim.role', true) = 'service_role'
    OR current_user = 'postgres'
    OR current_user = 'supabase_admin'
  );

  IF NOT is_privileged THEN
    NEW.is_premium = OLD.is_premium;
    NEW.premium_expires_at = OLD.premium_expires_at;
    NEW.subscription_tier = OLD.subscription_tier;
    NEW.role = OLD.role;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;
