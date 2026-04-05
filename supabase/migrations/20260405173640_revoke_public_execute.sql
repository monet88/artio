-- Migration: Fix REVOKE PUBLIC on SECURITY DEFINER functions
-- Explicitly revokes EXECUTE from PUBLIC on SECURITY DEFINER functions
-- and grants it to service_role to ensure background tasks retain execution privileges.

REVOKE EXECUTE ON FUNCTION deduct_credits(UUID, INTEGER, TEXT, TEXT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION deduct_credits(UUID, INTEGER, TEXT, TEXT) TO service_role;

REVOKE EXECUTE ON FUNCTION refund_credits(UUID, INTEGER, TEXT, TEXT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION refund_credits(UUID, INTEGER, TEXT, TEXT) TO service_role;

REVOKE EXECUTE ON FUNCTION handle_new_user() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION handle_new_user() TO service_role;

REVOKE EXECUTE ON FUNCTION update_subscription_status(UUID, BOOLEAN, TEXT, TIMESTAMPTZ) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION update_subscription_status(UUID, BOOLEAN, TEXT, TIMESTAMPTZ) TO service_role;
