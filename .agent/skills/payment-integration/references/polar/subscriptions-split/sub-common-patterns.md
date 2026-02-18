# Common Patterns

### Subscription Status Check
```typescript
async function hasActiveSubscription(userId) {
  const subscriptions = await polar.subscriptions.list({
    external_customer_id: userId,
    status: "active"
  });

  return subscriptions.items.length > 0;
}
```

### Grace Period Handler
```typescript
app.post('/webhook/polar', async (req, res) => {
  const event = validateEvent(req.body, req.headers, secret);

  if (event.type === 'subscription.past_due') {
    const subscription = event.data;

    // Grant 3-day grace period
    await grantGracePeriod(subscription.customer_id, 3);

    // Notify customer
    await sendPaymentFailedEmail(subscription.customer_id);
  }

  res.json({ received: true });
});
```

### Upgrade Path
```typescript
async function upgradeSubscription(subscriptionId, newPriceId) {
  // Preview invoice
  const preview = await polar.subscriptions.previewUpdate(subscriptionId, {
    product_price_id: newPriceId,
    proration: "invoice_immediately"
  });

  // Show customer preview
  if (await confirmUpgrade(preview)) {
    await polar.subscriptions.update(subscriptionId, {
      product_price_id: newPriceId,
      proration: "invoice_immediately"
    });
  }
}
```
