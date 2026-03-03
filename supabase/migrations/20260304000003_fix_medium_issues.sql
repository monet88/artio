-- Migration: Fix Medium Issues
-- Phase 5: Rename "order" to sort_order in templates table
-- Phase 6: Restrict storage + credit policies

-- ============================================================
-- Phase 5: Rename reserved-word column
-- ============================================================

ALTER TABLE templates RENAME COLUMN "order" TO sort_order;

-- ============================================================
-- Phase 6: Restrict storage + credit policies
-- ============================================================

-- 1. Restrict user-uploads upload policy to user's own folder
DROP POLICY IF EXISTS "Authenticated users can upload images" ON storage.objects;
CREATE POLICY "Authenticated users can upload images"
ON storage.objects FOR INSERT TO authenticated
WITH CHECK (
  bucket_id = 'user-uploads'
  AND (select auth.uid())::text = (storage.foldername(name))[1]
);

-- Also fix delete policy to restrict to own folder
DROP POLICY IF EXISTS "Authenticated users can delete uploads" ON storage.objects;
CREATE POLICY "Authenticated users can delete uploads"
ON storage.objects FOR DELETE TO authenticated
USING (
  bucket_id = 'user-uploads'
  AND (select auth.uid())::text = (storage.foldername(name))[1]
);

-- 2. Drop overly permissive credit_transactions INSERT policy
-- All inserts go through SECURITY DEFINER functions (deduct_credits, refund_credits, etc.)
DROP POLICY IF EXISTS "Service role can insert transactions" ON credit_transactions;
