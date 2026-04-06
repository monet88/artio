-- Revoke PUBLIC execution from the remaining SECURITY DEFINER signup trigger.
REVOKE EXECUTE ON FUNCTION public.handle_new_user() FROM PUBLIC;

-- Re-grant execution to the role used by backend automation paths.
GRANT EXECUTE ON FUNCTION public.handle_new_user() TO service_role;
