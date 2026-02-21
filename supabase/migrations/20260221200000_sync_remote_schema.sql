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
CREATE TABLE IF NOT EXISTS pending_ad_rewards (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  nonce UUID NOT NULL UNIQUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  expires_at TIMESTAMPTZ DEFAULT (NOW() + INTERVAL '5 minutes'),
  claimed BOOLEAN DEFAULT false
);
CREATE INDEX IF NOT EXISTS idx_pending_ad_rewards_nonce ON pending_ad_rewards(nonce);
CREATE INDEX IF NOT EXISTS idx_pending_ad_rewards_cleanup ON pending_ad_rewards(expires_at) WHERE claimed = false;
ALTER TABLE pending_ad_rewards ENABLE ROW LEVEL SECURITY;

-- =============================================================================
-- 3. Missing functions
-- =============================================================================

CREATE OR REPLACE FUNCTION check_rate_limit(
  p_user_id UUID,
  p_max_requests INTEGER DEFAULT 10,
  p_window_seconds INTEGER DEFAULT 60
)
RETURNS BOOLEAN
LANGUAGE plpgsql SECURITY DEFINER
SET search_path = 'public'
AS $$
DECLARE
  v_count INTEGER;
  v_window_start TIMESTAMPTZ;
BEGIN
  SELECT request_count, window_start INTO v_count, v_window_start
  FROM generation_rate_limits WHERE user_id = p_user_id FOR UPDATE;

  IF NOT FOUND THEN
    INSERT INTO generation_rate_limits (user_id, request_count, window_start)
    VALUES (p_user_id, 1, NOW());
    RETURN TRUE;
  END IF;

  IF v_window_start < NOW() - (p_window_seconds || ' seconds')::INTERVAL THEN
    UPDATE generation_rate_limits SET request_count = 1, window_start = NOW()
    WHERE user_id = p_user_id;
    RETURN TRUE;
  END IF;

  IF v_count >= p_max_requests THEN
    RETURN FALSE;
  END IF;

  UPDATE generation_rate_limits SET request_count = request_count + 1
  WHERE user_id = p_user_id;
  RETURN TRUE;
END;
$$;

CREATE OR REPLACE FUNCTION request_ad_nonce(p_user_id UUID)
RETURNS UUID
LANGUAGE plpgsql SECURITY DEFINER
SET search_path = 'public'
AS $$
DECLARE
  v_nonce UUID;
BEGIN
  DELETE FROM pending_ad_rewards WHERE user_id = p_user_id AND claimed = false;
  v_nonce := gen_random_uuid();
  INSERT INTO pending_ad_rewards (user_id, nonce) VALUES (p_user_id, v_nonce);
  RETURN v_nonce;
END;
$$;

CREATE OR REPLACE FUNCTION claim_ad_reward(p_user_id UUID, p_nonce UUID)
RETURNS BOOLEAN
LANGUAGE plpgsql SECURITY DEFINER
SET search_path = 'public'
AS $$
DECLARE
  v_found BOOLEAN;
BEGIN
  UPDATE pending_ad_rewards
  SET claimed = true
  WHERE user_id = p_user_id AND nonce = p_nonce AND claimed = false AND expires_at > NOW();
  GET DIAGNOSTICS v_found = ROW_COUNT;
  IF NOT v_found THEN RETURN FALSE; END IF;

  UPDATE user_credits SET balance = balance + 1 WHERE user_id = p_user_id;
  IF NOT FOUND THEN
    INSERT INTO user_credits (user_id, balance) VALUES (p_user_id, 1);
  END IF;

  INSERT INTO credit_transactions (user_id, amount, type, description, reference_id)
  VALUES (p_user_id, 1, 'ad_reward', 'Reward for watching ad', p_nonce::TEXT);
  RETURN TRUE;
END;
$$;

CREATE OR REPLACE FUNCTION reward_ad_credits(p_user_id UUID)
RETURNS VOID
LANGUAGE plpgsql SECURITY DEFINER
SET search_path = 'public'
AS $$
BEGIN
  UPDATE user_credits SET balance = balance + 1 WHERE user_id = p_user_id;
  IF NOT FOUND THEN
    INSERT INTO user_credits (user_id, balance) VALUES (p_user_id, 1);
  END IF;
  INSERT INTO credit_transactions (user_id, amount, type, description)
  VALUES (p_user_id, 1, 'ad_reward', 'Reward for watching ad');
END;
$$;

CREATE OR REPLACE FUNCTION update_subscription_status(
  p_user_id UUID,
  p_is_premium BOOLEAN,
  p_tier TEXT DEFAULT 'free',
  p_expires_at TIMESTAMPTZ DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql SECURITY DEFINER
SET search_path = 'public'
AS $$
BEGIN
  UPDATE profiles
  SET is_premium = p_is_premium,
      subscription_tier = p_tier,
      premium_expires_at = p_expires_at,
      updated_at = NOW()
  WHERE id = p_user_id;
END;
$$;

CREATE OR REPLACE FUNCTION grant_subscription_credits(
  p_user_id UUID,
  p_amount INTEGER,
  p_description TEXT DEFAULT 'Subscription credits',
  p_reference_id TEXT DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql SECURITY DEFINER
SET search_path = 'public'
AS $$
BEGIN
  UPDATE user_credits SET balance = balance + p_amount WHERE user_id = p_user_id;
  IF NOT FOUND THEN
    INSERT INTO user_credits (user_id, balance) VALUES (p_user_id, p_amount);
  END IF;
  INSERT INTO credit_transactions (user_id, amount, type, description, reference_id)
  VALUES (p_user_id, p_amount, 'subscription', p_description, p_reference_id);
END;
$$;

CREATE OR REPLACE FUNCTION prevent_premium_self_update()
RETURNS TRIGGER
LANGUAGE plpgsql SECURITY DEFINER
AS $$
BEGIN
  IF OLD.is_premium IS DISTINCT FROM NEW.is_premium
     OR OLD.subscription_tier IS DISTINCT FROM NEW.subscription_tier
     OR OLD.premium_expires_at IS DISTINCT FROM NEW.premium_expires_at THEN
    IF current_setting('role') != 'service_role' THEN
      NEW.is_premium := OLD.is_premium;
      NEW.subscription_tier := OLD.subscription_tier;
      NEW.premium_expires_at := OLD.premium_expires_at;
    END IF;
  END IF;
  RETURN NEW;
END;
$$;

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
