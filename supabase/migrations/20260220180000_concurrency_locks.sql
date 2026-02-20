-- =============================================================================
-- Migration: Add deduplication constraints
-- Enforces uniqueness on reference_id in credit_transactions for generation 
-- so users are not double-charged if 2 requests come at the exact same time
-- =============================================================================

CREATE UNIQUE INDEX IF NOT EXISTS uq_credit_transactions_generation_ref 
ON credit_transactions (reference_id) 
WHERE type = 'generation' AND reference_id IS NOT NULL;
