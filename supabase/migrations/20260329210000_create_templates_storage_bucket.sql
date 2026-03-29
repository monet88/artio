-- Migration: Create 'templates' storage bucket for admin thumbnail uploads
-- Created: 2026-03-29

-- =============================================================================
-- 1. Create templates bucket (public — thumbnails are publicly viewable)
-- =============================================================================

INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'templates',
  'templates',
  true,
  5242880, -- 5MB limit per file
  ARRAY['image/png', 'image/jpeg', 'image/webp', 'image/gif']
)
ON CONFLICT (id) DO NOTHING;

-- =============================================================================
-- 2. RLS Policies for templates bucket
-- =============================================================================

-- Anyone can view template thumbnails (public bucket content)
CREATE POLICY "Public can view template thumbnails"
ON storage.objects FOR SELECT
USING (bucket_id = 'templates');

-- Only authenticated admin users can upload thumbnails
-- Admin check mirrors the same pattern used in admin RPC functions:
-- profiles.role = 'admin'
CREATE POLICY "Admins can upload template thumbnails"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'templates'
  AND auth.role() = 'authenticated'
  AND EXISTS (
    SELECT 1 FROM public.profiles
    WHERE id = auth.uid()
    AND role = 'admin'
  )
);

-- Only authenticated admin users can update/replace thumbnails
CREATE POLICY "Admins can update template thumbnails"
ON storage.objects FOR UPDATE
USING (
  bucket_id = 'templates'
  AND auth.role() = 'authenticated'
  AND EXISTS (
    SELECT 1 FROM public.profiles
    WHERE id = auth.uid()
    AND role = 'admin'
  )
);

-- Only authenticated admin users can delete thumbnails
CREATE POLICY "Admins can delete template thumbnails"
ON storage.objects FOR DELETE
USING (
  bucket_id = 'templates'
  AND auth.role() = 'authenticated'
  AND EXISTS (
    SELECT 1 FROM public.profiles
    WHERE id = auth.uid()
    AND role = 'admin'
  )
);
