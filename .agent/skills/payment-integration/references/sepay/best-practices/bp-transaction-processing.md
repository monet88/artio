# Transaction Processing

### Complete Processing Flow
```typescript
async function processTransaction(payload: SepayWebhookPayload) {
  // 1. Only process incoming transfers
  if (payload.transferType !== 'in') {
    console.log('Skipping outbound transfer');
    return;
  }

  // 2. Find matching order
  const { order, matchMethod } = await findOrderByTransaction(payload);
  if (!order) {
    console.error('No matching order found');
    return;
  }

  // 3. Verify amount (allow overpayment)
  if (payload.transferAmount < order.amount) {
    console.error(`Underpayment: expected ${order.amount}, got ${payload.transferAmount}`);
    return;
  }
  if (payload.transferAmount > order.amount) {
    console.log(`Overpayment accepted: expected ${order.amount}, got ${payload.transferAmount}`);
  }

  // 4. Update order with transaction details
  const existingMetadata = order.metadata ? JSON.parse(order.metadata) : {};
  await db.update(orders)
    .set({
      status: 'completed',
      paymentId: String(payload.id),
      metadata: JSON.stringify({
        ...existingMetadata, // Preserve discount info
        gateway: payload.gateway,
        transactionDate: payload.transactionDate,
        accountNumber: payload.accountNumber,
        transferAmount: payload.transferAmount,
        content: payload.content,
        matchMethod,
        transactionId: payload.id,
      }),
      updatedAt: new Date(),
    })
    .where(eq(orders.id, order.id));

  // 5. Create license (non-blocking)
  try {
    await createLicense(order);
  } catch (error) {
    console.error('Failed to create license:', error);
  }

  // 6. Send confirmation email (non-blocking)
  try {
    await sendOrderConfirmation(order, payload);
  } catch (error) {
    console.error('Failed to send confirmation:', error);
  }

  // 7. Create referral commission (non-blocking)
  if (order.referredBy) {
    try {
      // Commission based on actual paid amount
      await createCommission({
        orderId: order.id,
        referrerId: order.referredBy,
        baseAmount: payload.transferAmount, // Actual paid amount
        currency: 'VND',
      });
    } catch (error) {
      console.error('Failed to create commission:', error);
    }
  }

  // 8. Update referrer tier (non-blocking)
  if (order.referredBy) {
    try {
      const usdConversion = await convertVndToUsd(payload.transferAmount);
      await updateReferrerTier(order.referredBy, usdConversion.usdCents, order.id);
    } catch (error) {
      console.error('Failed to update tier:', error);
    }
  }

  // 9. Grant GitHub access (non-blocking)
  try {
    const metadata = JSON.parse(order.metadata || '{}');
    await inviteToGitHub(metadata.githubUsername, order.productType);
  } catch (error) {
    console.error('Failed to invite to GitHub:', error);
  }

  // 10. Sync Polar discount redemption (non-blocking)
  const metadata = JSON.parse(order.metadata || '{}');
  if (metadata.couponId && metadata.couponCode) {
    try {
      await syncPolarDiscountWithRetry(order.id, metadata.couponId, metadata.couponCode);
    } catch (error) {
      console.error('Failed to sync Polar discount:', error);
      await sendDiscordAlert('Polar discount sync failed', { orderId: order.id });
    }
  }

  // 11. Send sales notification (non-blocking)
  try {
    await sendSalesNotification({
      ...order,
      gateway: payload.gateway,
      transactionId: payload.id,
    });
  } catch (error) {
    console.error('Failed to send Discord notification:', error);
  }
}
```
