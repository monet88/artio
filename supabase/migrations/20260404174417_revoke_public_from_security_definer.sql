-- Revoke PUBLIC execution from SECURITY DEFINER functions
REVOKE EXECUTE ON FUNCTION public.handle_new_user() FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION deduct_credits(UUID, INTEGER, TEXT, TEXT) FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION refund_credits(UUID, INTEGER, TEXT, TEXT) FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION update_subscription_status(UUID, BOOLEAN, TEXT, TIMESTAMPTZ) FROM PUBLIC;

-- Grant EXECUTE to service_role to ensure Edge Functions and background tasks retain execution privileges
GRANT EXECUTE ON FUNCTION public.handle_new_user() TO service_role;
GRANT EXECUTE ON FUNCTION deduct_credits(UUID, INTEGER, TEXT, TEXT) TO service_role;
GRANT EXECUTE ON FUNCTION refund_credits(UUID, INTEGER, TEXT, TEXT) TO service_role;
GRANT EXECUTE ON FUNCTION update_subscription_status(UUID, BOOLEAN, TEXT, TIMESTAMPTZ) TO service_role;
