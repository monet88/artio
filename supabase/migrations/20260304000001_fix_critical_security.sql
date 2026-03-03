-- Migration: Fix Critical Security Issues
-- Phase 1: Remove SECURITY DEFINER from prevent_premium_self_update()
-- Phase 2: Wrap all auth.uid() calls in (select ...) for RLS performance

-- ============================================================
-- Phase 1: Fix prevent_premium_self_update() — CRITICAL
-- The sync migration 20260221200000 re-created this with SECURITY DEFINER,
-- which makes current_user return the definer role, not the caller.
-- ============================================================

CREATE OR REPLACE FUNCTION prevent_premium_self_update()
RETURNS TRIGGER AS $$
DECLARE
  is_privileged BOOLEAN;
BEGIN
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
$$ LANGUAGE plpgsql;  -- NO SECURITY DEFINER — runs as INVOKER

-- ============================================================
-- Phase 2: Fix RLS policies — wrap auth.uid() with (select ...)
-- This caches the auth.uid() call per-query instead of per-row
-- ============================================================

-- profiles (3 policies)
DROP POLICY IF EXISTS "Users can view own profile" ON profiles;
CREATE POLICY "Users can view own profile" ON profiles FOR SELECT
USING ((select auth.uid()) = id);

DROP POLICY IF EXISTS "Users can update own profile" ON profiles;
CREATE POLICY "Users can update own profile" ON profiles FOR UPDATE
USING ((select auth.uid()) = id);

DROP POLICY IF EXISTS "Users can insert own profile" ON profiles;
CREATE POLICY "Users can insert own profile" ON profiles FOR INSERT
WITH CHECK ((select auth.uid()) = id);

-- generation_jobs (4 policies)
DROP POLICY IF EXISTS "Users can view own generation jobs" ON generation_jobs;
CREATE POLICY "Users can view own generation jobs" ON generation_jobs FOR SELECT
USING ((select auth.uid()) = user_id AND deleted_at IS NULL);

DROP POLICY IF EXISTS "Users can insert own generation jobs" ON generation_jobs;
CREATE POLICY "Users can insert own generation jobs" ON generation_jobs FOR INSERT
WITH CHECK ((select auth.uid()) = user_id);

DROP POLICY IF EXISTS "Users can update own generation jobs" ON generation_jobs;
CREATE POLICY "Users can update own generation jobs" ON generation_jobs FOR UPDATE
USING ((select auth.uid()) = user_id)
WITH CHECK ((select auth.uid()) = user_id);

DROP POLICY IF EXISTS "Admins can view all generation jobs" ON generation_jobs;
CREATE POLICY "Admins can view all generation jobs" ON generation_jobs FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM profiles
    WHERE profiles.id = (select auth.uid())
    AND profiles.role = 'admin'
  )
);

-- user_credits (1 policy)
DROP POLICY IF EXISTS "Users can view own credits" ON user_credits;
CREATE POLICY "Users can view own credits" ON user_credits FOR SELECT
USING ((select auth.uid()) = user_id);

-- ad_views (1 policy)
DROP POLICY IF EXISTS "Users can view own ad views" ON ad_views;
CREATE POLICY "Users can view own ad views" ON ad_views FOR SELECT
USING ((select auth.uid()) = user_id);

-- credit_transactions (1 policy)
DROP POLICY IF EXISTS "Users can view own transactions" ON credit_transactions;
CREATE POLICY "Users can view own transactions" ON credit_transactions FOR SELECT
USING ((select auth.uid()) = user_id);

-- templates — Admin policy
DROP POLICY IF EXISTS "Admins can manage templates" ON templates;
CREATE POLICY "Admins can manage templates" ON templates FOR ALL
USING (
  EXISTS (
    SELECT 1 FROM profiles
    WHERE profiles.id = (select auth.uid())
    AND profiles.role = 'admin'
  )
);

-- storage.objects — generated-images bucket (3 policies)
DROP POLICY IF EXISTS "Users can view own images" ON storage.objects;
CREATE POLICY "Users can view own images" ON storage.objects FOR SELECT
USING (
  bucket_id = 'generated-images'
  AND (select auth.uid())::text = (storage.foldername(name))[1]
);

DROP POLICY IF EXISTS "Users can delete own images" ON storage.objects;
CREATE POLICY "Users can delete own images" ON storage.objects FOR DELETE
USING (
  bucket_id = 'generated-images'
  AND (select auth.uid())::text = (storage.foldername(name))[1]
);

DROP POLICY IF EXISTS "Users can upload own images" ON storage.objects;
CREATE POLICY "Users can upload own images" ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'generated-images'
  AND (select auth.uid())::text = (storage.foldername(name))[1]
);
