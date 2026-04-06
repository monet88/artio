-- Migration: Revoke PUBLIC execution from critical SECURITY DEFINER functions
-- Fixes a critical vulnerability where unauthenticated (anon) users could
-- call these functions and grant themselves credits or modify subscription status.

-- PostgreSQL grants EXECUTE to PUBLIC by default for new functions.
-- For SECURITY DEFINER functions, this allows anyone to execute them
-- with the privileges of the creator (superuser) unless explicitly revoked.

REVOKE EXECUTE ON FUNCTION deduct_credits(UUID, INTEGER, TEXT, TEXT) FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION refund_credits(UUID, INTEGER, TEXT, TEXT) FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION update_subscription_status(UUID, BOOLEAN, TEXT, TIMESTAMPTZ) FROM PUBLIC;

-- Explicitly re-grant to service_role to ensure Edge Functions can still call them.
-- (service_role loses EXECUTE when it's revoked from PUBLIC because it inherited it).
GRANT EXECUTE ON FUNCTION deduct_credits(UUID, INTEGER, TEXT, TEXT) TO service_role;
GRANT EXECUTE ON FUNCTION refund_credits(UUID, INTEGER, TEXT, TEXT) TO service_role;
GRANT EXECUTE ON FUNCTION update_subscription_status(UUID, BOOLEAN, TEXT, TIMESTAMPTZ) TO service_role;
