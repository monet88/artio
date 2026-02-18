# Order Schema Design

### Unified Orders Table
```typescript
// db/schema/orders.ts
import { pgTable, uuid, text, integer, numeric, timestamp, boolean } from 'drizzle-orm/pg-core';

export const orders = pgTable('orders', {
  id: uuid('id').primaryKey().defaultRandom(),
  userId: uuid('user_id').references(() => users.id),
  email: text('email').notNull(),

  // Product info
  productType: text('product_type').notNull(), // 'engineer_kit', 'marketing_kit', 'combo', 'team_*'
  quantity: integer('quantity').default(1),

  // Pricing (stored in provider's currency)
  amount: integer('amount').notNull(),           // Final amount after discounts
  originalAmount: integer('original_amount'),    // Before any discounts
  currency: text('currency').default('USD'),     // 'USD' or 'VND'

  // Status
  status: text('status').default('pending'),     // pending, completed, failed, refunded

  // Provider info
  paymentProvider: text('payment_provider').notNull(), // 'polar' or 'sepay'
  paymentId: text('payment_id'),                 // External payment/transaction ID

  // Referral tracking
  referredBy: uuid('referred_by').references(() => users.id),
  discountAmount: integer('discount_amount').default(0),
  discountRate: numeric('discount_rate', { precision: 5, scale: 2 }),

  // Audit trail (JSON)
  metadata: text('metadata'),

  // Timestamps
  createdAt: timestamp('created_at').defaultNow(),
  updatedAt: timestamp('updated_at').defaultNow(),
});
```

### Provider-Specific Metadata
```typescript
// Polar order metadata
interface PolarOrderMetadata {
  originalAmount: number;
  couponCode?: string;
  couponDiscountAmount?: number;
  referralCode?: string;
  referralDiscountAmount?: number;
  referrerId?: string;
  githubUsername: string;
  polarDiscountId?: string;
  polarDiscountSynced?: boolean;
  polarDiscountSyncAction?: 'decremented' | 'deleted' | 'already_deleted';
  polarDiscountSyncedAt?: string;
  isTeamPurchase?: boolean;
  teamId?: string;
}

// SePay order metadata
interface SepayOrderMetadata {
  originalAmount: number;
  couponCode?: string;
  couponDiscountAmount?: number;
  couponId?: string;              // For Polar discount sync
  referralCode?: string;
  referralDiscountAmount?: number;
  referrerId?: string;
  githubUsername: string;
  vatInvoiceRequested?: boolean;
  encryptedTaxId?: string;
  // Added by webhook
  gateway?: string;
  transactionDate?: string;
  transactionId?: number;
  transferAmount?: number;
  matchMethod?: string;
  content?: string;
}
```
