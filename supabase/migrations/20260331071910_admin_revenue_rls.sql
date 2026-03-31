-- RLS policy: admins can read all credit_transactions
-- Uses (select auth.uid()) — evaluated once per query for performance

CREATE POLICY "Admins can read all transactions"
ON credit_transactions FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM profiles
    WHERE profiles.id = (select auth.uid())
    AND profiles.role = 'admin'
  )
);

-- Partial index on type + created_at for the revenue 7-day window queries
CREATE INDEX IF NOT EXISTS idx_credit_transactions_type_created
ON credit_transactions(type, created_at)
WHERE type IN ('subscription', 'purchase');
