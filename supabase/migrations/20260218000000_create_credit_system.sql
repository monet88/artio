-- =============================================================================
-- Migration: Complete Credit System
-- Creates user_credits, ad_views tables; alters credit_transactions;
-- adds deduct/refund helper functions; updates signup trigger with welcome bonus
-- =============================================================================

-- =============================================================================
-- 1. Create user_credits table
-- =============================================================================

CREATE TABLE IF NOT EXISTS user_credits (
  user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  balance INTEGER NOT NULL DEFAULT 0 CHECK (balance >= 0),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE user_credits ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own credits"
ON user_credits FOR SELECT
USING (auth.uid() = user_id);

CREATE OR REPLACE FUNCTION update_user_credits_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_user_credits_updated_at
BEFORE UPDATE ON user_credits
FOR EACH ROW EXECUTE FUNCTION update_user_credits_updated_at();

-- =============================================================================
-- 2. Create ad_views table
-- =============================================================================

CREATE TABLE IF NOT EXISTS ad_views (
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  view_date DATE NOT NULL DEFAULT CURRENT_DATE,
  view_count INTEGER NOT NULL DEFAULT 1 CHECK (view_count >= 0 AND view_count <= 10),
  PRIMARY KEY (user_id, view_date)
);

ALTER TABLE ad_views ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own ad views"
ON ad_views FOR SELECT
USING (auth.uid() = user_id);

-- =============================================================================
-- 3. Alter credit_transactions — add missing types and reference_id
-- =============================================================================

ALTER TABLE credit_transactions DROP CONSTRAINT IF EXISTS credit_transactions_type_check;

ALTER TABLE credit_transactions ADD CONSTRAINT credit_transactions_type_check
CHECK (type IN ('welcome_bonus', 'ad_reward', 'generation', 'refund', 'subscription', 'purchase', 'daily_reset', 'admin_grant', 'manual'));

ALTER TABLE credit_transactions ADD COLUMN IF NOT EXISTS reference_id TEXT;

CREATE INDEX IF NOT EXISTS idx_credit_transactions_reference_id ON credit_transactions(reference_id) WHERE reference_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_credit_transactions_user_created ON credit_transactions(user_id, created_at DESC);

-- =============================================================================
-- 4. Helper functions (SECURITY DEFINER)
-- =============================================================================

CREATE OR REPLACE FUNCTION deduct_credits(
  p_user_id UUID,
  p_amount INTEGER,
  p_description TEXT,
  p_reference_id TEXT DEFAULT NULL
) RETURNS BOOLEAN AS $$
DECLARE
  rows_affected INTEGER;
BEGIN
  UPDATE user_credits
  SET balance = balance - p_amount
  WHERE user_id = p_user_id AND balance >= p_amount;

  GET DIAGNOSTICS rows_affected = ROW_COUNT;

  IF rows_affected = 0 THEN
    RETURN FALSE;
  END IF;

  INSERT INTO credit_transactions (user_id, amount, type, description, reference_id)
  VALUES (p_user_id, -p_amount, 'generation', p_description, p_reference_id);

  RETURN TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION refund_credits(
  p_user_id UUID,
  p_amount INTEGER,
  p_description TEXT,
  p_reference_id TEXT DEFAULT NULL
) RETURNS VOID AS $$
BEGIN
  UPDATE user_credits
  SET balance = balance + p_amount
  WHERE user_id = p_user_id;

  INSERT INTO credit_transactions (user_id, amount, type, description, reference_id)
  VALUES (p_user_id, p_amount, 'refund', p_description, p_reference_id);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Security: Do NOT grant these to 'authenticated'.
-- They are SECURITY DEFINER with no auth.uid() check, so any authenticated
-- user could manipulate any account via RPC.  Only the Edge Function
-- (service_role) should call them.
REVOKE ALL ON FUNCTION deduct_credits(UUID, INTEGER, TEXT, TEXT) FROM authenticated;
REVOKE ALL ON FUNCTION refund_credits(UUID, INTEGER, TEXT, TEXT) FROM authenticated;

-- =============================================================================
-- 5. Update handle_new_user() — add welcome bonus
-- =============================================================================

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  -- Create profile (existing behavior)
  INSERT INTO public.profiles (id, email, full_name)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.email)
  );

  -- Initialize credit balance with welcome bonus
  INSERT INTO public.user_credits (user_id, balance)
  VALUES (NEW.id, 20);

  -- Log the welcome bonus transaction
  INSERT INTO public.credit_transactions (user_id, amount, type, description)
  VALUES (NEW.id, 20, 'welcome_bonus', 'Welcome bonus — 20 free credits');

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =============================================================================
-- 6. Backfill existing users with 0 credits (no welcome bonus)
-- =============================================================================

INSERT INTO user_credits (user_id, balance)
SELECT id, 0 FROM auth.users
ON CONFLICT (user_id) DO NOTHING;
