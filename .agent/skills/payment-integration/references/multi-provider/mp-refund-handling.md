# Refund Handling

### Unified Refund Flow
```typescript
// lib/refunds.ts
export async function processRefund(
  orderId: string,
  options: { keepAccess?: boolean; reason?: string }
): Promise<{ success: boolean; error?: string }> {
  const order = await db.select()
    .from(orders)
    .where(eq(orders.id, orderId))
    .limit(1);

  if (!order[0]) {
    return { success: false, error: 'Order not found' };
  }

  if (order[0].status !== 'completed') {
    return { success: false, error: 'Order not refundable' };
  }

  try {
    // 1. Process refund with payment provider
    if (order[0].paymentProvider === 'polar') {
      await polar.orders.refund({ id: order[0].paymentId! });
    } else {
      // SePay: Manual bank transfer refund required
      // Just mark order, admin handles bank transfer
      console.log(`Manual refund needed for SePay order ${orderId}`);
    }

    // 2. Update order status
    await db.update(orders)
      .set({
        status: 'refunded',
        metadata: JSON.stringify({
          ...JSON.parse(order[0].metadata || '{}'),
          refundedAt: new Date().toISOString(),
          refundReason: options.reason,
          keepAccess: options.keepAccess,
        }),
        updatedAt: new Date(),
      })
      .where(eq(orders.id, orderId));

    // 3. Cancel commission (if any)
    if (order[0].referredBy) {
      await db.update(commissions)
        .set({
          status: 'cancelled',
          cancelledAt: new Date(),
        })
        .where(eq(commissions.orderId, orderId));

      // Recalculate referrer tier
      await recalculateReferrerTier(order[0].referredBy);
    }

    // 4. Revoke access (unless keepAccess)
    if (!options.keepAccess) {
      const metadata = JSON.parse(order[0].metadata || '{}');
      if (metadata.githubUsername) {
        await revokeGitHubAccess(metadata.githubUsername, order[0].productType);
      }

      await db.update(licenses)
        .set({ isActive: false, revokedAt: new Date() })
        .where(eq(licenses.orderId, orderId));
    }

    return { success: true };

  } catch (error) {
    console.error('Refund failed:', error);
    return { success: false, error: error instanceof Error ? error.message : 'Refund failed' };
  }
}
```
