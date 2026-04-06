-- =============================================================================
-- Migration: Fix SECURITY DEFINER leak on update_subscription_status
--
-- Problem: update_subscription_status is marked SECURITY DEFINER but its execution
-- was not revoked from PUBLIC. By default, PostgreSQL grants EXECUTE to PUBLIC on
-- new functions, meaning any user (including anon) could potentially escalate their
-- own subscription status.
--
-- Fix:
--   1. Revoke EXECUTE from PUBLIC
--   2. Revoke EXECUTE from authenticated (though already implicitly covered if not granted)
--   3. Explicitly GRANT EXECUTE to service_role (needed for Edge Functions to use it)
-- =============================================================================

REVOKE EXECUTE ON FUNCTION update_subscription_status(UUID, BOOLEAN, TEXT, TIMESTAMPTZ) FROM PUBLIC;

-- Only service_role should call this function
REVOKE EXECUTE ON FUNCTION update_subscription_status(UUID, BOOLEAN, TEXT, TIMESTAMPTZ) FROM authenticated;

-- Re-grant to service_role explicitly: after revoking from PUBLIC, service_role loses EXECUTE
-- because it inherited from PUBLIC. Edge functions run as service_role and must retain access.
GRANT EXECUTE ON FUNCTION update_subscription_status(UUID, BOOLEAN, TEXT, TIMESTAMPTZ) TO service_role;
