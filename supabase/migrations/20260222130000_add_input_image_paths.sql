-- Migration: Add input_image_paths column to generation_jobs
-- Purpose: Track uploaded input images for cleanup on job deletion
-- Created: 2026-02-22

ALTER TABLE generation_jobs
ADD COLUMN IF NOT EXISTS input_image_paths TEXT[] DEFAULT NULL;

COMMENT ON COLUMN generation_jobs.input_image_paths IS
  'Storage-relative paths of user-uploaded input images (e.g. userId/inputs/uuid.jpg). Used for cleanup on deletion.';
