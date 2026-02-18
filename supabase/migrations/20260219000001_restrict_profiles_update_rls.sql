-- =============================================================================
-- Migration: Restrict Profiles UPDATE — protect subscription columns
-- Prevents users from directly modifying subscription-related columns via the
-- existing "Users can update own profile" RLS policy.
-- Uses a BEFORE UPDATE trigger that silently resets protected columns to their
-- original values for non-service-role callers.
-- =============================================================================

CREATE OR REPLACE FUNCTION prevent_premium_self_update()
RETURNS TRIGGER AS $$
BEGIN
  -- Only allow service_role to modify these columns
  IF current_setting('role') != 'service_role' THEN
    NEW.is_premium = OLD.is_premium;
    NEW.premium_expires_at = OLD.premium_expires_at;
    NEW.subscription_tier = OLD.subscription_tier;
    NEW.revenuecat_app_user_id = OLD.revenuecat_app_user_id;
    NEW.role = OLD.role;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER protect_subscription_columns
BEFORE UPDATE ON profiles
FOR EACH ROW
EXECUTE FUNCTION prevent_premium_self_update();
