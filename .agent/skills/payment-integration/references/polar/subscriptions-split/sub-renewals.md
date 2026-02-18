# Renewals

### Listening to Renewals
```typescript
app.post('/webhook/polar', async (req, res) => {
  const event = validateEvent(req.body, req.headers, secret);

  if (event.type === 'order.created') {
    const order = event.data;

    if (order.billing_reason === 'subscription_cycle') {
      // This is a renewal
      await handleRenewal(order.subscription_id);
    }
  }

  res.json({ received: true });
});
```

### Failed Renewals
- `subscription.past_due` webhook fired
- Dunning process initiated
- Customer notified via email
- Multiple retry attempts
- Eventually revoked if payment fails
