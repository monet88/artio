# Database Schema

### Orders Table
```typescript
// db/schema/orders.ts
export const orders = pgTable('orders', {
  id: uuid('id').primaryKey().defaultRandom(),
  userId: uuid('user_id').references(() => users.id),
  email: text('email').notNull(),
  productType: text('product_type').notNull(),
  amount: integer('amount').notNull(), // Final amount in cents
  originalAmount: integer('original_amount'), // Before discounts
  currency: text('currency').default('USD'),
  status: text('status').default('pending'), // pending, completed, failed, refunded
  paymentProvider: text('payment_provider').notNull(), // 'polar' or 'sepay'
  paymentId: text('payment_id'), // External payment ID
  referredBy: uuid('referred_by').references(() => users.id),
  discountAmount: integer('discount_amount').default(0),
  discountRate: numeric('discount_rate', { precision: 5, scale: 2 }),
  metadata: text('metadata'), // JSON with audit trail
  createdAt: timestamp('created_at').defaultNow(),
  updatedAt: timestamp('updated_at').defaultNow(),
});
```

### Webhook Events Table (Idempotency)
```typescript
export const webhookEvents = pgTable('webhook_events', {
  id: uuid('id').primaryKey().defaultRandom(),
  provider: text('provider').notNull(), // 'polar' or 'sepay'
  eventType: text('event_type').notNull(),
  eventId: text('event_id').notNull().unique(), // Idempotency key
  payload: text('payload').notNull(),
  processed: boolean('processed').default(false),
  processedAt: timestamp('processed_at'),
  error: text('error'),
  createdAt: timestamp('created_at').defaultNow(),
});
```
