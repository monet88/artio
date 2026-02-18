# Discount Cross-Provider Sync

### Syncing SePay Usage to Polar
```typescript
// lib/polar-discount-sync.ts
// When a Polar discount is used via SePay, decrement Polar's redemption count

export async function syncDiscountRedemptionToPolar(
  orderId: string,
  discountId: string,
  discountCode: string
): Promise<{ success: boolean; action: string }> {
  const order = await db.select()
    .from(orders)
    .where(eq(orders.id, orderId))
    .limit(1);

  if (!order[0]) {
    return { success: false, action: 'order_not_found' };
  }

  const metadata = order[0].metadata ? JSON.parse(order[0].metadata) : {};

  // Idempotency check
  if (metadata.polarDiscountSynced) {
    return { success: true, action: 'already_synced' };
  }

  const polar = getPolar();

  try {
    const discount = await polar.discounts.get({ id: discountId });

    // Skip if unlimited redemptions
    if (discount.maxRedemptions === null) {
      await markSynced(orderId, 'skipped_unlimited');
      return { success: true, action: 'skipped_unlimited' };
    }

    const currentMax = discount.maxRedemptions;

    if (currentMax <= 1) {
      // Delete discount if this was last use
      await polar.discounts.delete({ id: discountId });
      await markSynced(orderId, 'deleted');
      return { success: true, action: 'deleted' };
    } else {
      // Decrement max redemptions
      await polar.discounts.update({
        id: discountId,
        discountUpdate: { maxRedemptions: currentMax - 1 },
      });
      await markSynced(orderId, 'decremented');
      return { success: true, action: 'decremented' };
    }

  } catch (error: any) {
    if (error.statusCode === 404) {
      await markSynced(orderId, 'already_deleted');
      return { success: true, action: 'already_deleted' };
    }
    throw error;
  }
}

async function markSynced(orderId: string, action: string) {
  const order = await db.select().from(orders).where(eq(orders.id, orderId)).limit(1);
  const metadata = order[0].metadata ? JSON.parse(order[0].metadata) : {};

  await db.update(orders)
    .set({
      metadata: JSON.stringify({
        ...metadata,
        polarDiscountSynced: true,
        polarDiscountSyncAction: action,
        polarDiscountSyncedAt: new Date().toISOString(),
      }),
    })
    .where(eq(orders.id, orderId));
}

// Retry wrapper with exponential backoff
export async function syncWithRetry(
  orderId: string,
  discountId: string,
  discountCode: string,
  attempt: number = 1
): Promise<{ success: boolean; action: string }> {
  const MAX_ATTEMPTS = 3;

  try {
    return await syncDiscountRedemptionToPolar(orderId, discountId, discountCode);
  } catch (error) {
    if (attempt < MAX_ATTEMPTS) {
      const delay = Math.pow(2, attempt) * 1000; // 2s, 4s
      await sleep(delay);
      return syncWithRetry(orderId, discountId, discountCode, attempt + 1);
    }
    throw error;
  }
}
```
