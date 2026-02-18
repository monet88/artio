# Events

**Webhook Events:**
- `checkout.created` - Session created
- `checkout.updated` - Session updated
- `order.created` - Order created after successful payment
- `order.paid` - Payment confirmed

**Handle Success:**
```typescript
// Listen to order.paid webhook
app.post('/webhook/polar', async (req, res) => {
  const event = validateEvent(req.body, req.headers, secret);

  if (event.type === 'order.paid') {
    const order = event.data;
    await fulfillOrder(order);
  }

  res.json({ received: true });
});
```
