# Error Handling Patterns

### Fail-Open for Non-Critical Operations
```typescript
// Discount creation fails → proceed with full price
try {
  const discount = await createReferralDiscount(productId, amount, referralCode);
  polarDiscountId = discount.id;
} catch (error) {
  console.error('⚠️ Discount creation failed - proceeding with full price:', error);
  // Flag for manual refund investigation
  await flagOrderForReview(orderId, 'discount_creation_failed');
}
```

### Graceful Degradation in Webhooks
```typescript
// Non-critical operations don't block order completion
const operations = [
  { name: 'GitHub invite', fn: () => inviteToGitHub(username, productType) },
  { name: 'Welcome email', fn: () => sendWelcomeEmail(order) },
  { name: 'Discord notification', fn: () => sendSalesNotification(order) },
  { name: 'Tier update', fn: () => updateReferrerTier(referrerId, revenueUsd) },
];

for (const op of operations) {
  try {
    await op.fn();
  } catch (error) {
    console.error(`❌ ${op.name} failed:`, error);
    // Continue processing - don't block order
  }
}
```

### Rate Limit Handling with Exponential Backoff
```typescript
async function callWithRetry<T>(
  fn: () => Promise<T>,
  maxRetries: number = 3
): Promise<T> {
  let attempt = 0;

  while (attempt < maxRetries) {
    try {
      return await fn();
    } catch (error: any) {
      if (error.statusCode === 429) {
        const retryAfter = parseInt(error.headers?.['retry-after'] || '1', 10);
        const delay = retryAfter * 1000 * Math.pow(2, attempt);
        console.log(`Rate limited, retrying in ${delay}ms...`);
        await sleep(delay);
        attempt++;
      } else {
        throw error;
      }
    }
  }

  throw new Error('Max retries exceeded');
}
```
