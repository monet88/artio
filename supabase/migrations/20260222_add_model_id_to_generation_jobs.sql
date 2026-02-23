-- Migration: Add model_id column to generation_jobs
-- Bug fix: Dart client inserts model_id but column was missing → "Something went wrong"
-- Created: 2026-02-22

ALTER TABLE generation_jobs
  ADD COLUMN IF NOT EXISTS model_id TEXT;
