# Discount Management

### Discount Validation with Timeout
```typescript
// lib/polar-discounts.ts
const VALIDATION_TIMEOUT_MS = 15000;

export async function validateDiscount(
  code: string,
  productId: string
): Promise<{ valid: boolean; discount?: PolarDiscount; reason?: string }> {
  const sanitizedCode = code.trim().toUpperCase();
  if (!sanitizedCode) {
    return { valid: false, reason: 'Code cannot be empty' };
  }

  const polar = getPolar();
  const env = getPolarEnv();

  try {
    // Race against timeout
    const timeoutPromise = new Promise<never>((_, reject) => {
      setTimeout(() => reject(new Error('Validation timeout')), VALIDATION_TIMEOUT_MS);
    });

    const searchPromise = polar.discounts.list({
      organizationId: env.POLAR_ORGANIZATION_ID,
      query: sanitizedCode,
      limit: 100,
    });

    const result = await Promise.race([searchPromise, timeoutPromise]);

    // Find exact match
    const discount = result.items.find(d =>
      d.code?.toUpperCase() === sanitizedCode
    );

    if (!discount) {
      return { valid: false, reason: 'Code not found' };
    }

    // Check eligibility
    const now = new Date();
    if (discount.startsAt && now < new Date(discount.startsAt)) {
      return { valid: false, reason: `Code starts on ${discount.startsAt}` };
    }
    if (discount.endsAt && now > new Date(discount.endsAt)) {
      return { valid: false, reason: 'Code has expired' };
    }
    if (discount.maxRedemptions && discount.redemptionsCount >= discount.maxRedemptions) {
      return { valid: false, reason: 'Code redemption limit reached' };
    }
    if (!discount.products?.some(p => p.id === productId)) {
      return { valid: false, reason: 'Code not valid for this product' };
    }

    return { valid: true, discount };

  } catch (error) {
    console.error('Discount validation error:', error);
    return { valid: false, reason: 'Validation failed - please try again' };
  }
}
```

### VND Conversion for Discounts
```typescript
const VND_TO_USD_RATE = 25000; // 1 USD = 25,000 VND

export function convertDiscountToVND(discount: PolarDiscount, amountVND: number): number {
  if (discount.type === 'percentage') {
    // Basis points: 1000 = 10%, 10000 = 100%
    const percentage = discount.basisPoints / 10000;
    return Math.round(amountVND * percentage);
  } else {
    // Fixed amount in USD cents → VND
    const amountUSD = discount.amount / 100;
    return Math.round(amountUSD * VND_TO_USD_RATE);
  }
}
```

### Syncing SePay Redemptions to Polar
```typescript
// lib/polar-discount-sync.ts
// When SePay payment completes, decrement Polar discount redemptions

export async function syncPolarDiscountRedemption(
  orderId: string,
  discountId: string,
  discountCode: string
): Promise<{ success: boolean; action: string }> {
  const order = await db.select().from(orders).where(eq(orders.id, orderId)).limit(1);
  if (!order[0]) {
    return { success: false, action: 'order_not_found' };
  }

  // Idempotency check
  const metadata = order[0].metadata ? JSON.parse(order[0].metadata) : {};
  if (metadata.polarDiscountSynced) {
    return { success: true, action: 'already_synced' };
  }

  const polar = getPolar();

  try {
    const discount = await polar.discounts.get({ id: discountId });

    if (discount.maxRedemptions === null || discount.maxRedemptions === undefined) {
      return { success: true, action: 'skipped_unlimited' };
    }

    const currentMax = discount.maxRedemptions;

    if (currentMax <= 1) {
      await polar.discounts.delete({ id: discountId });
      await markOrderSynced(orderId, 'deleted');
    } else {
      await polar.discounts.update({
        id: discountId,
        discountUpdate: { maxRedemptions: currentMax - 1 },
      });
      await markOrderSynced(orderId, 'decremented');
    }

    return { success: true, action: currentMax <= 1 ? 'deleted' : 'decremented' };

  } catch (error: any) {
    if (error.statusCode === 404) {
      // Already deleted - treat as success
      await markOrderSynced(orderId, 'already_deleted');
      return { success: true, action: 'already_deleted' };
    }
    throw error;
  }
}

async function markOrderSynced(orderId: string, action: string) {
  const order = await db.select().from(orders).where(eq(orders.id, orderId)).limit(1);
  const metadata = order[0].metadata ? JSON.parse(order[0].metadata) : {};

  metadata.polarDiscountSynced = true;
  metadata.polarDiscountSyncAction = action;
  metadata.polarDiscountSyncedAt = new Date().toISOString();

  await db.update(orders)
    .set({ metadata: JSON.stringify(metadata) })
    .where(eq(orders.id, orderId));
}
```
