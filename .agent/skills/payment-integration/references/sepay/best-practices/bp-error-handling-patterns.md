# Error Handling Patterns

### Always Return 200 to SePay
```typescript
// Webhook must always return 200 to prevent retry loop
export async function POST(request: Request) {
  try {
    // ... processing
  } catch (error) {
    // Log error but don't fail
    console.error('Webhook processing error:', error);
    await logWebhookError(error);
  }

  // ALWAYS return 200
  return NextResponse.json({ success: true });
}
```

### Non-Blocking Post-Payment Operations
```typescript
// Wrap each operation in try-catch
const operations = [
  { name: 'License', fn: () => createLicense(order) },
  { name: 'Email', fn: () => sendOrderConfirmation(order) },
  { name: 'Commission', fn: () => createCommission(order) },
  { name: 'GitHub', fn: () => inviteToGitHub(username, productType) },
  { name: 'Discord', fn: () => sendSalesNotification(order) },
];

for (const op of operations) {
  try {
    await op.fn();
    console.log(`✅ ${op.name} completed`);
  } catch (error) {
    console.error(`❌ ${op.name} failed:`, error);
    // Continue - don't block other operations
  }
}
```

### Amount Validation
```typescript
// Reject underpayment, accept overpayment
if (transferAmount < order.amount) {
  console.error(`Underpayment: expected ${order.amount}, received ${transferAmount}`);
  await flagOrderForReview(order.id, 'underpayment');
  return; // Don't process
}

if (transferAmount > order.amount) {
  console.log(`Overpayment: expected ${order.amount}, received ${transferAmount}`);
  // Continue processing - customer paid more than required
}
```
