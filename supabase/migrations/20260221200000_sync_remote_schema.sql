-- Sync remote schema with local migrations
-- This migration applies missing schema to the production project
-- that was set up partially from dashboard

-- =============================================================================
-- 1. Missing columns on profiles
-- =============================================================================
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'profiles' AND column_name = 'is_premium') THEN
    ALTER TABLE profiles ADD COLUMN is_premium BOOLEAN DEFAULT false;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'profiles' AND column_name = 'subscription_tier') THEN
    ALTER TABLE profiles ADD COLUMN subscription_tier TEXT DEFAULT 'free';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'profiles' AND column_name = 'premium_expires_at') THEN
    ALTER TABLE profiles ADD COLUMN premium_expires_at TIMESTAMPTZ;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'profiles' AND column_name = 'revenuecat_app_user_id') THEN
    ALTER TABLE profiles ADD COLUMN revenuecat_app_user_id TEXT;
  END IF;
END $$;

-- =============================================================================
-- 2. Missing tables
-- =============================================================================

-- generation_rate_limits
CREATE TABLE IF NOT EXISTS generation_rate_limits (
  user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  request_count INTEGER DEFAULT 0,
  window_start TIMESTAMPTZ DEFAULT NOW()
);
ALTER TABLE generation_rate_limits ENABLE ROW LEVEL SECURITY;

-- pending_ad_rewards
-- This sync migration predates the later claimed_at-based normalization. Guard
-- the legacy shape so fresh local bootstrap can coexist with the newer schema.
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.tables
    WHERE table_schema = 'public' AND table_name = 'pending_ad_rewards'
  ) THEN
    CREATE TABLE pending_ad_rewards (
      id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
      user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
      nonce UUID NOT NULL UNIQUE,
      created_at TIMESTAMPTZ DEFAULT NOW(),
      expires_at TIMESTAMPTZ DEFAULT (NOW() + INTERVAL '5 minutes'),
      claimed BOOLEAN DEFAULT false
    );
    CREATE INDEX IF NOT EXISTS idx_pending_ad_rewards_nonce ON pending_ad_rewards(nonce);
    CREATE INDEX IF NOT EXISTS idx_pending_ad_rewards_cleanup
      ON pending_ad_rewards(expires_at) WHERE claimed = false;
  ELSIF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'pending_ad_rewards' AND column_name = 'expires_at'
  ) AND EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'pending_ad_rewards' AND column_name = 'claimed'
  ) THEN
    CREATE INDEX IF NOT EXISTS idx_pending_ad_rewards_cleanup
      ON pending_ad_rewards(expires_at) WHERE claimed = false;
  END IF;

  ALTER TABLE pending_ad_rewards ENABLE ROW LEVEL SECURITY;
END $$;

-- =============================================================================
-- 3. Missing functions
-- =============================================================================
-- Legacy remote backfill intentionally skipped for fresh local bootstrap.
-- Canonical function definitions are provided by later migrations in this repo.

-- =============================================================================
-- 4. Missing trigger
-- =============================================================================
DROP TRIGGER IF EXISTS protect_subscription_columns ON profiles;
CREATE TRIGGER protect_subscription_columns
BEFORE UPDATE ON profiles
FOR EACH ROW EXECUTE FUNCTION prevent_premium_self_update();

-- =============================================================================
-- 5. Missing policies for admin on generation_jobs
-- =============================================================================
DROP POLICY IF EXISTS "Admins can view all generation jobs" ON generation_jobs;
CREATE POLICY "Admins can view all generation jobs"
ON generation_jobs FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM profiles
    WHERE profiles.id = auth.uid()
    AND profiles.role = 'admin'
  )
);

-- =============================================================================
-- 6. Missing unique index on credit_transactions
-- =============================================================================
CREATE UNIQUE INDEX IF NOT EXISTS uq_credit_transactions_generation_ref
ON credit_transactions(reference_id) WHERE type = 'generation';

-- =============================================================================
-- 7. Service role policy for credit_transactions
-- =============================================================================
DROP POLICY IF EXISTS "Service role can insert transactions" ON credit_transactions;
CREATE POLICY "Service role can insert transactions"
ON credit_transactions FOR INSERT
WITH CHECK (true);

-- =============================================================================
-- 8. Extension pg_net (if available)
-- =============================================================================
CREATE EXTENSION IF NOT EXISTS pg_net WITH SCHEMA extensions;

-- =============================================================================
-- 9. Storage policies for user-uploads bucket
-- =============================================================================
INSERT INTO storage.buckets (id, name, public)
VALUES ('user-uploads', 'user-uploads', true)
ON CONFLICT (id) DO NOTHING;

DROP POLICY IF EXISTS "Authenticated users can upload images" ON storage.objects;
CREATE POLICY "Authenticated users can upload images"
ON storage.objects FOR INSERT TO authenticated
WITH CHECK (bucket_id = 'user-uploads');

DROP POLICY IF EXISTS "Authenticated users can delete uploads" ON storage.objects;
CREATE POLICY "Authenticated users can delete uploads"
ON storage.objects FOR DELETE TO authenticated
USING (bucket_id = 'user-uploads');

DROP POLICY IF EXISTS "Public can view uploads" ON storage.objects;
CREATE POLICY "Public can view uploads"
ON storage.objects FOR SELECT
USING (bucket_id = 'user-uploads');
