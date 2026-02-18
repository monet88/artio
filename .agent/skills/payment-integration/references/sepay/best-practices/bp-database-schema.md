# Database Schema

### Orders Table Extensions for SePay
```typescript
// Fields used specifically for SePay
{
  paymentId: text('payment_id'),      // Transaction content or TEAM{8} code
  paymentProvider: literal('sepay'),  // Distinguishes from Polar
  currency: literal('VND'),           // Always VND for SePay
  amount: integer('amount'),          // In VND (no decimals)
}

// Metadata JSON includes:
{
  gateway: string,           // Bank name from webhook
  transactionDate: string,   // Webhook timestamp
  transactionId: number,     // SePay transaction ID
  transferAmount: number,    // Actual received amount
  matchMethod: string,       // How order was matched
  content: string,           // Original transaction memo
  encryptedTaxId?: string,   // For VAT invoices
}
```

### Recommended Indexes
```sql
CREATE INDEX idx_orders_sepay_pending ON orders (status, payment_provider, amount)
  WHERE status = 'pending' AND payment_provider = 'sepay';

CREATE INDEX idx_orders_sepay_timestamp ON orders (created_at)
  WHERE payment_provider = 'sepay';

CREATE INDEX idx_orders_payment_id ON orders (payment_id)
  WHERE payment_provider = 'sepay';
```
