-- Migration: Fix REVOKE PUBLIC + Rename stale index
-- Fixes from PR #47 review:
--   1. Revoke EXECUTE from PUBLIC on SECURITY DEFINER functions
--      (CREATE FUNCTION grants to PUBLIC by default)
--   2. Rename idx_templates_order to reflect column rename

-- ============================================================
-- Fix 1: Revoke PUBLIC access on SECURITY DEFINER functions
-- ============================================================

REVOKE EXECUTE ON FUNCTION check_rate_limit(UUID, INTEGER, INTEGER) FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION request_ad_nonce(UUID) FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION claim_ad_reward(UUID, UUID) FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION reward_ad_credits(UUID) FROM PUBLIC;

-- ============================================================
-- Fix 2: Rename stale index (cosmetic, index already works)
-- ============================================================

ALTER INDEX IF EXISTS idx_templates_order RENAME TO idx_templates_sort_order;
